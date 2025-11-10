# Design Document

## Overview

This design document outlines the technical approach for improving the terraform-lab infrastructure codebase. The improvements are organized into four phases: Security Hardening, Code Quality Improvements, Best Practices Implementation, and Tooling & Documentation. The design ensures backward compatibility while modernizing the codebase to follow current Terraform and AWS best practices.

## Architecture

### High-Level Design Principles

1. **Backward Compatibility First**: All changes must maintain existing functionality
2. **Security by Default**: Secure configurations should be the default, with opt-out where necessary
3. **DRY (Don't Repeat Yourself)**: Eliminate code duplication through locals and modules
4. **Fail Fast**: Use validation and error handling to catch issues early
5. **Documentation as Code**: Generate documentation from code where possible

### Module Structure

The existing module structure will be preserved:

```
terraform-lab/
├── main.tf                    # Root module (refactored with locals)
├── variables.tf               # Enhanced with types and validation
├── versions.tf                # NEW: Version constraints
├── backend.tf                 # Updated provider version
├── locals.tf                  # NEW: Common computed values
├── global/                    # Global infrastructure
│   ├── vpc/                   # Enhanced with VPC endpoints
│   ├── iam/
│   ├── route53/
│   └── ...
├── microsoft/                 # Windows services (refactored)
│   ├── main.tf               # Reduced duplication with locals
│   ├── locals.tf             # NEW: Common Windows config
│   └── */                    # Individual service modules
├── unix/                      # Unix services (refactored)
│   ├── main.tf               # Reduced duplication with locals
│   ├── locals.tf             # NEW: Common Unix config
│   └── */                    # Individual service modules
├── user_data/                 # Enhanced with error handling
│   └── config-win.ps1        # Secrets Manager integration
├── post_setup/                # Enhanced with error handling
│   ├── Join-domain-member.ps1
│   └── New-Secrets.ps1
└── .kiro/
    └── specs/
        └── infrastructure-improvements/
```

## Components and Interfaces

### Component 1: Security Hardening Layer

**Purpose**: Implement secure-by-default configurations

**Key Files**:

- `variables.tf`: New security-related variables
- `user_data/config-win.ps1`: Secrets Manager integration
- `microsoft/main.tf`: Restricted security groups
- `unix/main.tf`: Restricted security groups

**Interfaces**:

```hcl
# New variables for security
variable "admin_cidr_blocks" {
  description = "CIDR blocks allowed for administrative access (RDP, SSH, WinRM)"
  type        = list(string)
  default     = ["10.0.0.0/16"]  # Default to VPC CIDR only
  
  validation {
    condition     = alltrue([for cidr in var.admin_cidr_blocks : can(cidrhost(cidr, 0))])
    error_message = "All admin_cidr_blocks must be valid CIDR notation."
  }
}

variable "enable_public_admin_access" {
  description = "Allow administrative access from internet (not recommended for production)"
  type        = bool
  default     = false
}
```

**Security Group Pattern**:

```hcl
# Computed admin CIDR blocks based on configuration
locals {
  admin_cidr_blocks = var.enable_public_admin_access ? ["0.0.0.0/0"] : var.admin_cidr_blocks
}

resource "aws_security_group" "rdp" {
  name        = "tf_ezlab_rdp"
  description = "Administrative access for Windows servers"
  vpc_id      = var.aws_vpc_id

  ingress {
    description = "RDP access from authorized networks"
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = local.admin_cidr_blocks
  }
  
  # ... other rules
}
```

**PowerShell Secrets Integration**:

```powershell
# Enhanced user data with Secrets Manager
function Get-SecretSafely {
    param(
        [string]$SecretId,
        [string]$Region
    )
    
    try {
        $secret = (Get-SECSecretValue -SecretId $SecretId -Region $Region -ErrorAction Stop).SecretString
        
        if ([string]::IsNullOrEmpty($secret)) {
            throw "Secret value is empty for $SecretId"
        }
        
        return $secret
    }
    catch {
        Write-EventLog -LogName Application -Source "EC2Config" `
            -EntryType Error -EventId 1001 `
            -Message "Failed to retrieve secret $SecretId : $_"
        throw
    }
}

# Usage
$region = Invoke-RestMethod -Uri http://169.254.169.254/latest/meta-data/placement/region
$password = Get-SecretSafely -SecretId "ez-lab.xyz/ansible/localadmin" -Region $region
```

### Component 2: Code Deduplication Layer

**Purpose**: Eliminate repetitive code through locals and computed values

**Key Files**:

- `locals.tf` (new root-level file)
- `microsoft/locals.tf` (new)
- `unix/locals.tf` (new)
- `global/main.tf` (refactored)

**Locals Structure**:

```hcl
# Root locals.tf
locals {
  # Common tags applied to all resources
  common_tags = {
    Project     = "terraform-lab"
    ManagedBy   = "Terraform"
    Environment = "lab"
    Repository  = "github.com/user/terraform-lab"
  }
  
  # Computed CIDR blocks for all subnet types
  cidr_blocks = {
    back = [
      for i in range(length(var.azs)) :
      cidrsubnet(module.global.vpc_cidr, 8, var.cidrbyte["back${i + 1}.${var.aws_region}"])
    ]
    
    backup = [
      for i in range(length(var.azs)) :
      cidrsubnet(module.global.vpc_cidr, 8, var.cidrbyte["backup${i + 1}.${var.aws_region}"])
    ]
    
    web = [
      for i in range(length(var.azs)) :
      cidrsubnet(module.global.vpc_cidr, 8, var.cidrbyte["web${i + 1}.${var.aws_region}"])
    ]
    
    exchange = [
      for i in range(length(var.azs)) :
      cidrsubnet(module.global.vpc_cidr, 8, var.cidrbyte["exchange${i + 1}.${var.aws_region}"])
    ]
    
    mgmt = [
      for i in range(length(var.azs)) :
      cidrsubnet(module.global.vpc_cidr, 8, var.cidrbyte["mgmt${i + 1}.${var.aws_region}"])
    ]
    
    sql = [
      for i in range(length(var.azs)) :
      cidrsubnet(module.global.vpc_cidr, 8, var.cidrbyte["sql${i + 1}.${var.aws_region}"])
    ]
  }
}

# microsoft/locals.tf
locals {
  # Common configuration for all Windows modules
  common_windows_config = {
    aws_ami                 = data.aws_ami.windows2022.id
    aws_iip_assumerole_name = var.aws_iip_assumerole_name
    aws_key_pair_auth_id    = var.aws_key_pair_auth_id
    aws_region              = var.aws_region
    aws_vpc_id              = var.aws_vpc_id
    azs                     = var.azs
    dns_zone_id             = var.dns_zone_id
    dns_suffix              = var.dns_suffix
    dns_public_zone_id      = var.dns_public_zone_id
  }
  
  # Common security groups for Windows servers
  common_windows_sg_ids = flatten([
    aws_security_group.rdp.id,
    aws_security_group.domain-member.id,
    module.simpana.aws_sg_client_id,
    var.aws_sg_nbuclient_ids,
  ])
  
  # Subnet-specific security groups
  back_subnet_sg_ids = local.common_windows_sg_ids
  web_subnet_sg_ids  = local.common_windows_sg_ids
  mgmt_subnet_sg_ids = local.common_windows_sg_ids
}
```

**Module Call Pattern (Before)**:

```hcl
module "adfs" {
  source                  = "./adfs"
  aws_ami                 = data.aws_ami.windows2022.id
  aws_iip_assumerole_name = var.aws_iip_assumerole_name
  aws_key_pair_auth_id    = var.aws_key_pair_auth_id
  aws_number              = var.aws_number["adfs"]
  aws_region              = var.aws_region
  aws_subnet_id           = var.aws_subnet_web_id
  aws_vpc_id              = var.aws_vpc_id
  azs                     = var.azs
  dns_zone_id             = var.dns_zone_id
  dns_suffix              = var.dns_suffix
  cidr                    = [/* 3 lines of cidrsubnet calls */]
  aws_sg_ids              = flatten([/* 5 lines */])
}
```

**Module Call Pattern (After)**:

```hcl
module "adfs" {
  source = "./adfs"
  
  # Service-specific config
  aws_number    = var.aws_number["adfs"]
  aws_subnet_id = var.aws_subnet_web_id
  cidr          = local.cidr_blocks.web
  aws_sg_ids    = local.web_subnet_sg_ids
  
  # Common config (spread operator)
  aws_ami                 = local.common_windows_config.aws_ami
  aws_iip_assumerole_name = local.common_windows_config.aws_iip_assumerole_name
  aws_key_pair_auth_id    = local.common_windows_config.aws_key_pair_auth_id
  aws_region              = local.common_windows_config.aws_region
  aws_vpc_id              = local.common_windows_config.aws_vpc_id
  azs                     = local.common_windows_config.azs
  dns_zone_id             = local.common_windows_config.dns_zone_id
  dns_suffix              = local.common_windows_config.dns_suffix
}
```

### Component 3: Type Safety and Validation Layer

**Purpose**: Catch configuration errors early with proper types and validation

**Enhanced Variables**:

```hcl
# variables.tf
variable "aws_region" {
  description = "AWS region for infrastructure deployment"
  type        = string
  default     = "eu-west-1"
  
  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]$", var.aws_region))
    error_message = "AWS region must be a valid region identifier (e.g., eu-west-1, us-east-1)."
  }
}

variable "aws_number" {
  description = "Number of instances to create for each service type (0-10)"
  type        = map(number)  # Changed from map(string)
  
  default = {
    dc         = 0
    guacamole  = 1
    # ... rest
  }
  
  validation {
    condition     = alltrue([for v in values(var.aws_number) : v >= 0 && v <= 10])
    error_message = "Instance counts must be between 0 and 10."
  }
}

variable "access_key" {
  description = "AWS access key (prefer using IAM roles or AWS SSO instead)"
  type        = string
  default     = ""
  sensitive   = true
  
  validation {
    condition     = var.access_key == "" || can(regex("^AKIA[0-9A-Z]{16}$", var.access_key))
    error_message = "Access key must be empty or a valid AWS access key format."
  }
}

variable "secret_key" {
  description = "AWS secret key (prefer using IAM roles or AWS SSO instead)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "public_key" {
  description = "SSH public key for EC2 instance access"
  type        = string
  
  validation {
    condition     = can(regex("^ssh-(rsa|ed25519|ecdsa)", var.public_key))
    error_message = "Public key must be a valid SSH public key."
  }
}

variable "azs" {
  description = "List of AWS availability zones for resource distribution"
  type        = list(string)
  
  default = ["eu-west-1a"]
  
  validation {
    condition     = length(var.azs) > 0 && length(var.azs) <= 3
    error_message = "Must specify 1-3 availability zones."
  }
}

variable "cidrbyte" {
  description = "Third octet values for subnet CIDR blocks (10.0.X.0/24)"
  type        = map(number)  # Changed from map(string)
  
  validation {
    condition     = alltrue([for v in values(var.cidrbyte) : v >= 0 && v <= 255])
    error_message = "CIDR byte values must be between 0 and 255."
  }
}
```

### Component 4: VPC Endpoint Enhancement

**Purpose**: Reduce costs and improve security with VPC endpoints

**New VPC Endpoint Resources**:

```hcl
# global/vpc/main.tf

# Security group for VPC endpoints
resource "aws_security_group" "vpc_endpoints" {
  name        = "tf_ezlab_vpc_endpoints"
  description = "Security group for VPC interface endpoints"
  vpc_id      = aws_vpc.ezlab.id

  ingress {
    description = "HTTPS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.ezlab.cidr_block]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "vpc-endpoints-sg"
  }
}

# SSM endpoint for Systems Manager
resource "aws_vpc_endpoint" "ssm" {
  vpc_id              = aws_vpc.ezlab.id
  service_name        = "com.amazonaws.${var.aws_region}.ssm"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.back[*].id
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  private_dns_enabled = true

  tags = {
    Name = "ssm-endpoint"
  }
}

# EC2 Messages endpoint for Systems Manager
resource "aws_vpc_endpoint" "ec2messages" {
  vpc_id              = aws_vpc.ezlab.id
  service_name        = "com.amazonaws.${var.aws_region}.ec2messages"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.back[*].id
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  private_dns_enabled = true

  tags = {
    Name = "ec2messages-endpoint"
  }
}

# SSM Messages endpoint for Systems Manager
resource "aws_vpc_endpoint" "ssmmessages" {
  vpc_id              = aws_vpc.ezlab.id
  service_name        = "com.amazonaws.${var.aws_region}.ssmmessages"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.back[*].id
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  private_dns_enabled = true

  tags = {
    Name = "ssmmessages-endpoint"
  }
}

# Secrets Manager endpoint
resource "aws_vpc_endpoint" "secretsmanager" {
  vpc_id              = aws_vpc.ezlab.id
  service_name        = "com.amazonaws.${var.aws_region}.secretsmanager"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.back[*].id
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  private_dns_enabled = true

  tags = {
    Name = "secretsmanager-endpoint"
  }
}

# Update existing S3 endpoint to use variable
resource "aws_vpc_endpoint" "private-s3" {
  vpc_id       = aws_vpc.ezlab.id
  service_name = "com.amazonaws.${var.aws_region}.s3"  # Changed from hardcoded
  policy       = file("./policy_json/vpc-policy-s3endpoint.json")

  tags = {
    Name = "s3-endpoint"
  }
}
```

### Component 5: Provider Configuration Enhancement

**Purpose**: Standardize provider configuration with version constraints and default tags

**versions.tf** (new file):

```hcl
terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
```

**backend.tf** (updated):

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"  # Updated from 3.0
    }
  }
  
  backend "remote" {
    organization = "fjacquet"
    
    workspaces {
      name = "terraform-lab"
    }
  }
}

provider "aws" {
  region     = var.aws_region
  access_key = var.access_key
  secret_key = var.secret_key
  
  # Default tags applied to all resources
  default_tags {
    tags = {
      Project     = "terraform-lab"
      ManagedBy   = "Terraform"
      Environment = "lab"
      Repository  = "github.com/user/terraform-lab"
    }
  }
}

data "aws_s3_bucket" "tf-config" {
  bucket = "tf-config"
}

resource "aws_key_pair" "auth" {
  key_name   = var.key_name
  public_key = var.public_key
}
```

### Component 6: IMDSv2 Enforcement

**Purpose**: Ensure all EC2 instances use IMDSv2 for enhanced security

**Pattern for All Instance Resources**:

```hcl
resource "aws_instance" "example" {
  ami           = var.aws_ami
  instance_type = "t3.medium"
  # ... other config
  
  metadata_options {
    http_tokens                 = "required"  # Enforce IMDSv2
    http_put_response_hop_limit = 1
    http_endpoint               = "enabled"
  }
  
  # ... rest of config
}
```

**Updated User Data for IMDSv2**:

```powershell
# Use IMDSv2 token-based authentication
$token = Invoke-RestMethod -Uri http://169.254.169.254/latest/api/token `
    -Method PUT `
    -Headers @{"X-aws-ec2-metadata-token-ttl-seconds" = "21600"}

$instanceId = Invoke-RestMethod -Uri http://169.254.169.254/latest/meta-data/instance-id `
    -Headers @{"X-aws-ec2-metadata-token" = $token}

$region = Invoke-RestMethod -Uri http://169.254.169.254/latest/meta-data/placement/region `
    -Headers @{"X-aws-ec2-metadata-token" = $token}
```

## Data Models

### Configuration Data Model

```hcl
# Hierarchical configuration structure
{
  global: {
    vpc: {
      cidr: "10.0.0.0/16"
      subnets: {
        back: ["10.0.51.0/24", "10.0.52.0/24", "10.0.53.0/24"]
        web: ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
        # ...
      }
      endpoints: ["ssm", "ec2messages", "secretsmanager", "s3"]
    }
    iam: { /* ... */ }
    route53: { /* ... */ }
  }
  
  microsoft: {
    common_config: { /* shared Windows config */ }
    services: {
      adds: { count: 0, subnet: "back", ami: "windows2022" }
      adfs: { count: 0, subnet: "web", ami: "windows2022" }
      # ...
    }
  }
  
  unix: {
    common_config: { /* shared Unix config */ }
    services: {
      guacamole: { count: 1, subnet: "mgmt", ami: "debian" }
      # ...
    }
  }
}
```

### Security Configuration Model

```hcl
{
  security_groups: {
    rdp: {
      ingress: [
        { port: 3389, protocol: "tcp", cidr: var.admin_cidr_blocks }
        { port: 22, protocol: "tcp", cidr: var.admin_cidr_blocks }
        { port: 5985-5986, protocol: "tcp", cidr: var.admin_cidr_blocks }
      ]
    }
    domain_member: {
      ingress: [
        { port: 53, protocol: "tcp/udp", self: true }
        { port: 88, protocol: "tcp/udp", self: true }
        # ... AD-specific ports
      ]
    }
  }
  
  secrets: {
    ansible_password: "ez-lab.xyz/ansible/localadmin"
    domain_join: "ez-lab.xyz/ad/joinuser"
    # ...
  }
}
```

## Error Handling

### Terraform Error Handling

**Variable Validation Errors**:

- Clear, actionable error messages
- Examples of valid input in error messages
- Validation at variable declaration time

**Resource Creation Errors**:

- Use `depends_on` for explicit dependencies
- Implement proper lifecycle rules
- Use `precondition` and `postcondition` blocks where appropriate

```hcl
resource "aws_instance" "example" {
  # ...
  
  lifecycle {
    precondition {
      condition     = var.aws_number >= 0
      error_message = "Instance count must be non-negative"
    }
    
    postcondition {
      condition     = self.instance_state == "running"
      error_message = "Instance failed to reach running state"
    }
  }
}
```

### PowerShell Error Handling

**Standard Error Handling Pattern**:

```powershell
function Invoke-SafeOperation {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$OperationName,
        
        [Parameter(Mandatory)]
        [scriptblock]$ScriptBlock
    )
    
    try {
        Write-Verbose "Starting: $OperationName"
        $result = & $ScriptBlock
        Write-Verbose "Completed: $OperationName"
        return $result
    }
    catch {
        $errorMessage = "Failed: $OperationName - $_"
        Write-Error $errorMessage
        
        # Log to Windows Event Log
        try {
            Write-EventLog -LogName Application -Source "EC2Config" `
                -EntryType Error -EventId 1000 `
                -Message $errorMessage
        }
        catch {
            # Event log write failed, continue
            Write-Warning "Could not write to event log: $_"
        }
        
        throw
    }
}

# Usage
Invoke-SafeOperation -OperationName "Retrieve Secret" -ScriptBlock {
    Get-SECSecretValue -SecretId $secretId -Region $region -ErrorAction Stop
}
```

### Ansible Error Handling

**Playbook Error Handling**:

```yaml
---
- name: Configure Windows servers
  hosts: tag_system_windows
  gather_facts: yes
  
  tasks:
    - name: Critical operation
      win_feature:
        name: Web-Server
        state: present
      register: result
      failed_when: result.failed or result.reboot_required
      
    - name: Handle failure
      debug:
        msg: "Operation failed: {{ result }}"
      when: result.failed
```

## Testing Strategy

### Phase 1: Unit Testing (Terraform Validation)

**Validation Tests**:

```bash
# Syntax validation
terraform fmt -check -recursive
terraform validate

# Variable validation
terraform plan -var-file=test.tfvars

# Module validation
for module in global microsoft unix; do
  cd $module
  terraform init
  terraform validate
  cd ..
done
```

### Phase 2: Integration Testing (Terraform Plan)

**Plan Tests**:

```bash
# Generate plan with test variables
terraform plan -var="aws_number={dc=1,guacamole=1}" -out=test.tfplan

# Verify no unexpected changes
terraform show -json test.tfplan | jq '.resource_changes[] | select(.change.actions[] | contains("delete"))'

# Verify security group restrictions
terraform show -json test.tfplan | jq '.resource_changes[] | select(.type=="aws_security_group") | .change.after.ingress[] | select(.cidr_blocks[] | contains("0.0.0.0/0"))'
```

### Phase 3: Deployment Testing (Staged Rollout)

**Test Environment Deployment**:

1. Deploy to isolated test VPC
2. Verify all resources created successfully
3. Test connectivity and functionality
4. Validate security configurations
5. Test PowerShell scripts on test instances
6. Run Ansible playbooks against test instances

**Validation Checklist**:

- [ ] All EC2 instances use IMDSv2
- [ ] Security groups restrict admin access
- [ ] Secrets retrieved from Secrets Manager
- [ ] VPC endpoints created and functional
- [ ] Tags applied to all resources
- [ ] No hardcoded credentials in user data
- [ ] PowerShell scripts handle errors
- [ ] Ansible playbooks execute successfully

### Phase 4: Backward Compatibility Testing

**Compatibility Tests**:

```bash
# Test with existing variable values
terraform plan -var-file=production.tfvars

# Verify no resource recreation
terraform plan | grep -E "(destroy|replace)"

# Test moved blocks
terraform state list
terraform plan -target=module.example
```

## Migration Strategy

### Phase 1: Preparation (No Changes)

1. Create feature branch
2. Run full terraform plan on current state
3. Document current resource counts and IDs
4. Backup current state file

### Phase 2: Non-Breaking Changes

1. Add versions.tf
2. Add locals.tf files
3. Update provider configuration with default tags
4. Add new variables with defaults
5. Deploy and verify no changes

### Phase 3: Security Hardening

1. Update security groups with new variables
2. Deploy with `enable_public_admin_access = true` (maintains current behavior)
3. Update user data scripts with Secrets Manager
4. Create secrets in AWS Secrets Manager
5. Test with new user data
6. Update documentation

### Phase 4: Code Refactoring

1. Refactor module calls to use locals
2. Use moved blocks for any resource renames
3. Deploy and verify no resource recreation
4. Update variable types (with defaults maintaining compatibility)
5. Add validation rules

### Phase 5: VPC Enhancements

1. Add VPC endpoints
2. Deploy incrementally
3. Verify connectivity through endpoints
4. Monitor costs

### Phase 6: Documentation and Tooling

1. Generate module documentation
2. Add pre-commit hooks
3. Update README files
4. Create migration guide

## Rollback Plan

### Immediate Rollback (Git Revert)

```bash
# Revert to previous commit
git revert HEAD
terraform init
terraform plan
terraform apply
```

### Partial Rollback (Targeted)

```bash
# Rollback specific resources
terraform state rm aws_vpc_endpoint.ssm
terraform import aws_security_group.rdp sg-xxxxx
```

### State Recovery

```bash
# Restore from backup
terraform state pull > current-state.backup
terraform state push previous-state.backup
```

## Performance Considerations

### Terraform Performance

- Use `-parallelism=50` for faster applies
- Implement resource targeting for large changes
- Use workspaces for environment isolation

### VPC Endpoint Benefits

- Reduced data transfer costs (no NAT gateway charges for AWS services)
- Improved latency for AWS API calls
- Enhanced security (traffic stays in VPC)

### Ansible Performance

- Fact caching reduces gather time
- Pipelining reduces SSH overhead
- Parallel execution with `strategy: free`

## Security Considerations

### Secrets Management

- All credentials stored in AWS Secrets Manager
- Secrets retrieved at runtime, never in code
- Automatic secret rotation supported
- Audit trail via CloudTrail

### Network Security

- Default deny for administrative access
- Explicit allow for required traffic
- Security group rules documented
- VPC endpoints for AWS service access

### Instance Security

- IMDSv2 enforced on all instances
- Encrypted EBS volumes
- IAM roles instead of access keys
- Systems Manager for secure access

## Monitoring and Observability

### Terraform State Monitoring

- State file encryption enabled
- State locking with DynamoDB
- State backup before major changes

### Resource Monitoring

- CloudWatch Logs for user data execution
- Windows Event Logs for PowerShell errors
- VPC Flow Logs for network traffic
- CloudTrail for API activity

### Cost Monitoring

- Resource tagging for cost allocation
- VPC endpoint cost tracking
- Regular cost reviews

## Documentation Requirements

### Module Documentation

Each module must include:

- README.md with usage examples
- Input variable documentation
- Output documentation
- Dependencies and requirements

### Operational Documentation

- Deployment procedures
- Rollback procedures
- Troubleshooting guide
- Security configuration guide

### Code Documentation

- Inline comments for complex logic
- Variable descriptions
- Security group rule descriptions
- Locals block documentation
