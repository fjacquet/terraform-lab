# Design Document

## Overview

This design document outlines the technical approach for improving the terraform-lab infrastructure codebase. The improvements address 21 requirements organized into security hardening, code quality improvements, best practices implementation, and tooling & documentation. The design ensures backward compatibility while modernizing the codebase to follow current Terraform and AWS best practices, with a focus on the DRY (Don't Repeat Yourself) and KISS (Keep It Simple, Stupid) principles.

## Architecture

### High-Level Design Principles

1. **Backward Compatibility First**: All changes must maintain existing functionality (Requirement 20)
2. **Security by Default**: Secure configurations should be the default, with opt-out where necessary (Requirements 1, 2, 16)
3. **DRY (Don't Repeat Yourself)**: Eliminate code duplication through locals and modules (Requirement 21.1)
4. **KISS (Keep It Simple, Stupid)**: Favor simplicity over complexity in all implementations (Requirement 21.2)
5. **Fail Fast**: Use validation and error handling to catch issues early (Requirements 5, 6, 14, 17)
6. **Documentation as Code**: Generate documentation from code where possible (Requirement 12)
7. **Explicit Over Implicit**: Use explicit version constraints and type definitions (Requirements 3, 5)

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

**Purpose**: Standardize provider configuration with version constraints and default tags (Requirements 3, 7)

**Design Rationale**:

- Using Terraform >= 1.0 ensures access to modern features like moved blocks and improved validation (Requirement 3.1)
- AWS provider ~> 5.0 constraint allows patch updates while preventing breaking changes (Requirement 3.2)
- Default tags at provider level ensure consistent tagging without repetition, following DRY principle (Requirement 7.1-7.2)
- Separate versions.tf file makes version management explicit and easy to audit (Requirement 3.3)
- Tags include Project, ManagedBy, Environment, and Repository for cost tracking and resource management (Requirement 7.2)

**versions.tf** (new file):

```hcl
terraform {
  required_version = ">= 1.0"  # Requirement 3.1
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"  # Requirement 3.2 - pessimistic constraint
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
      version = "~> 5.0"  # Updated from 3.0 (Requirement 3.2)
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
  
  # Default tags applied to all resources (Requirement 7.1-7.3)
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

## Design Decisions and Rationale

### Key Design Decisions

**1. Security-First Approach (Requirements 1, 2, 16)**

**Decision**: Implement restrictive security defaults with opt-out capability rather than permissive defaults with opt-in security.

**Rationale**:

- Follows security best practices and principle of least privilege
- Reduces risk of accidental exposure in production environments
- Provides `enable_public_admin_access` flag for development/testing scenarios
- Default CIDR blocks restrict to RFC1918 private networks (10.0.0.0/16)
- IMDSv2 enforcement prevents SSRF attacks against metadata service

**Trade-offs**:

- Requires explicit configuration for public access scenarios
- May require additional setup for remote access in some environments
- Benefit: Significantly improved security posture outweighs minor inconvenience

**2. Locals-Based Code Deduplication (Requirements 4, 19, 21.1)**

**Decision**: Use locals blocks to define common configurations once and reference them across modules.

**Rationale**:

- Achieves 60%+ reduction in code duplication (Requirement 4.4)
- Single source of truth for common values reduces errors
- Easier to maintain and update configurations
- Follows DRY principle (Requirement 21.1)
- Groups related values logically (Requirement 19.1)

**Trade-offs**:

- Slightly more complex initial setup
- Requires understanding of locals vs variables
- Benefit: Dramatically improved maintainability and reduced error potential

**3. Type Safety and Validation (Requirements 5, 17)**

**Decision**: Add explicit types and validation rules to all variables.

**Rationale**:

- Catches configuration errors before apply (fail fast principle)
- Provides clear error messages for invalid inputs (Requirement 17.5)
- Documents expected input formats
- Prevents common mistakes (e.g., string "0" vs number 0)
- Improves IDE autocomplete and documentation

**Trade-offs**:

- More verbose variable declarations
- Requires updating existing configurations
- Benefit: Prevents costly runtime errors and improves developer experience

**4. VPC Endpoints for Cost and Security (Requirement 10)**

**Decision**: Add interface endpoints for SSM, EC2 Messages, SSM Messages, and Secrets Manager.

**Rationale**:

- Reduces data transfer costs (no NAT gateway charges for AWS services)
- Improves security (traffic stays within VPC)
- Reduces latency for AWS API calls
- Enables private subnet instances to access AWS services without internet access
- Essential for Secrets Manager integration (Requirement 1.1)

**Trade-offs**:

- Additional cost for interface endpoints (~$7.20/month per endpoint)
- Increased complexity in VPC configuration
- Benefit: Cost savings from reduced NAT gateway usage typically offset endpoint costs, plus security benefits

**5. IMDSv2 Enforcement (Requirements 1.5, 16)**

**Decision**: Enforce IMDSv2 on all EC2 instances with http_tokens="required".

**Rationale**:

- Prevents SSRF attacks against metadata service
- AWS security best practice
- Required for compliance in many environments
- Minimal impact on properly written applications
- User data scripts updated to use token-based authentication

**Trade-offs**:

- Requires updating user data scripts to use tokens
- May break legacy applications that use IMDSv1
- Benefit: Significant security improvement with minimal effort

**6. Secrets Manager Integration (Requirements 1.1, 1.2)**

**Decision**: Replace hardcoded credentials with AWS Secrets Manager retrieval.

**Rationale**:

- Eliminates credentials from code and version control
- Enables credential rotation without code changes
- Provides audit trail via CloudTrail
- Follows AWS security best practices
- Supports compliance requirements

**Trade-offs**:

- Additional AWS service dependency
- Requires initial secret creation
- Slight increase in complexity
- Benefit: Dramatically improved security posture and compliance

**7. Backward Compatibility Strategy (Requirement 20)**

**Decision**: Use sensible defaults and moved blocks to maintain compatibility.

**Rationale**:

- Prevents disruption to existing deployments
- Allows gradual adoption of new features
- Uses Terraform moved blocks to handle resource renames
- New variables have defaults matching current behavior
- Provides migration guide for breaking changes

**Trade-offs**:

- Some defaults may not be optimal for new deployments
- Requires careful testing of upgrade path
- Benefit: Enables safe adoption without downtime

**8. Simplified Module Interfaces (Requirement 21.2 - KISS)**

**Decision**: Use locals to simplify module calls while maintaining flexibility.

**Rationale**:

- Reduces cognitive load when reading module calls
- Makes common patterns obvious
- Easier to identify service-specific configuration
- Maintains flexibility for special cases
- Follows KISS principle

**Trade-offs**:

- Requires understanding of locals structure
- Less explicit at call site
- Benefit: Dramatically improved readability and maintainability

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

### Testing Approach

**Design Rationale**:

- Multi-phase testing ensures quality at each level
- Validation tests catch errors early (fail fast principle)
- Integration tests verify interactions between components
- Backward compatibility tests prevent breaking changes (Requirement 20)

### Phase 1: Unit Testing (Terraform Validation)

**Validation Tests** (Requirements 3, 5, 17):

```bash
# Syntax validation (Requirement 9.4)
terraform fmt -check -recursive
terraform validate

# Variable validation (Requirements 5, 17)
terraform plan -var-file=test.tfvars

# Module validation (Requirement 3.5)
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

- [ ] All EC2 instances use IMDSv2 (Requirement 16.1-16.3)
- [ ] Security groups restrict admin access (Requirements 2.1-2.3)
- [ ] Security group rules have descriptions (Requirement 18.1-18.2)
- [ ] Secrets retrieved from Secrets Manager (Requirement 1.1)
- [ ] VPC endpoints created and functional (Requirements 10.1-10.5)
- [ ] Tags applied to all resources (Requirement 7.3)
- [ ] No hardcoded credentials in user data (Requirement 1.1)
- [ ] No hardcoded regions in code (Requirements 8.1, 8.4, 8.5)
- [ ] PowerShell scripts handle errors (Requirements 6.1-6.5)
- [ ] Ansible playbooks execute successfully (Requirement 11)
- [ ] Variable types are explicit (Requirement 5.1-5.2)
- [ ] Variable validation rules work (Requirement 17.1-17.5)
- [ ] Module documentation exists (Requirements 12.1-12.5)
- [ ] Pre-commit hooks function (Requirements 13.1-13.4)

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

## Code Cleanup and Maintainability (Requirement 9)

### Cleanup Strategy

**Design Rationale**:

- Commented-out code creates confusion and maintenance burden
- Historical context belongs in version control, not comments
- Consistent formatting improves readability
- Clean code follows KISS principle (Requirement 21.2)

**Cleanup Actions**:

1. **Remove Commented-Out Resources** (Requirement 9.1):
   - `main.tf`: Remove commented aws_vpc_dhcp_options block
   - `global/main.tf`: Remove commented providers and s3 modules
   - `microsoft/main.tf`: Remove commented dfs module
   - Document removal reasons in commit messages

2. **Remove Commented-Out Variables** (Requirement 9.2):
   - Audit all `variables.tf` files
   - Remove unused variable declarations
   - Document deprecated variables in MIGRATION.md

3. **Document Historical Context** (Requirement 9.3):
   - Move important historical notes to README.md
   - Document architectural decisions in design.md
   - Use git history for code evolution tracking

4. **Consistent Formatting** (Requirements 9.4, 9.5):
   - Run `terraform fmt -recursive` on all Terraform files
   - Use consistent PowerShell formatting (4-space indentation)
   - Enforce via pre-commit hooks

**Formatting Standards**:

```hcl
# Terraform formatting
- 2-space indentation
- Align equals signs in blocks
- One blank line between resources
- Group related resources together

# PowerShell formatting
- 4-space indentation
- Opening braces on same line
- Consistent parameter formatting
- Use approved verbs (Verb-Noun)
```

**Maintenance Benefits**:

- Easier code review and understanding
- Reduced cognitive load for developers
- Faster onboarding for new team members
- Fewer merge conflicts

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

## Terraform State Management

### State Backend Configuration (Requirement 15)

**Current Configuration**: Terraform Cloud remote backend

**Design Rationale**:

- Terraform Cloud provides built-in state locking (Requirement 15.1)
- State encryption at rest is enabled by default (Requirement 15.2)
- Workspace isolation prevents concurrent modification conflicts
- Automatic state versioning and backup
- No additional DynamoDB table required (handled by Terraform Cloud)

**Backend Configuration**:

```hcl
terraform {
  backend "remote" {
    organization = "fjacquet"
    
    workspaces {
      name = "terraform-lab"
    }
  }
}
```

**State Management Best Practices**:

1. **State Locking**: Automatically handled by Terraform Cloud (Requirement 15.1)
2. **Encryption**: State encrypted at rest by Terraform Cloud (Requirement 15.2)
3. **Sensitive Data**: Marked sensitive in outputs to prevent exposure (Requirement 15.3)
4. **Backup Strategy**: Terraform Cloud maintains state history
5. **Access Control**: Managed through Terraform Cloud workspace permissions

**Alternative S3 Backend Configuration** (if migrating from Terraform Cloud):

```hcl
terraform {
  backend "s3" {
    bucket         = "terraform-state-bucket"
    key            = "terraform-lab/terraform.tfstate"
    region         = "eu-west-1"
    encrypt        = true                    # Requirement 15.2
    dynamodb_table = "terraform-state-locks" # Requirement 15.1
    kms_key_id     = "arn:aws:kms:..."      # Requirement 15.3
  }
}
```

**Documentation Requirements** (Requirement 15.4-15.5):

- Backend configuration documented in README.md
- Workspace setup instructions in MIGRATION.md
- State management procedures in operational documentation
- Backup and recovery procedures documented

## Region Parameterization (Requirement 8)

### Multi-Region Support Design

**Design Rationale**:

- Enables deployment to any AWS region without code changes
- Supports disaster recovery and multi-region architectures
- Eliminates hardcoded region references
- Follows infrastructure-as-code best practices

**Parameterization Strategy**:

1. **Terraform Resources** (Requirements 8.1, 8.3, 8.4):
   - Use `var.aws_region` in all service names
   - Construct VPC endpoint service names dynamically
   - Example: `com.amazonaws.${var.aws_region}.s3`
   - No hardcoded region strings in any `.tf` files

2. **PowerShell Scripts** (Requirements 8.2, 8.5):
   - Retrieve region from instance metadata
   - Use IMDSv2 token-based authentication
   - Cache region value for script duration
   - Example:

     ```powershell
     $token = Invoke-RestMethod -Uri http://169.254.169.254/latest/api/token `
         -Method PUT -Headers @{"X-aws-ec2-metadata-token-ttl-seconds" = "21600"}
     $region = Invoke-RestMethod -Uri http://169.254.169.254/latest/meta-data/placement/region `
         -Headers @{"X-aws-ec2-metadata-token" = $token}
     ```

3. **Service Name Construction**:

   ```hcl
   # VPC Endpoints
   service_name = "com.amazonaws.${var.aws_region}.ssm"
   service_name = "com.amazonaws.${var.aws_region}.ec2messages"
   service_name = "com.amazonaws.${var.aws_region}.secretsmanager"
   service_name = "com.amazonaws.${var.aws_region}.s3"
   ```

**Validation**:

- Region variable includes validation for valid AWS region format
- Prevents typos and invalid region specifications
- Clear error messages for invalid inputs

**Benefits**:

- Deploy to any AWS region with single variable change
- Support multi-region disaster recovery
- Easier testing in different regions
- Compliance with data residency requirements

## Performance Considerations

### Terraform Performance

- Use `-parallelism=50` for faster applies
- Implement resource targeting for large changes
- Use workspaces for environment isolation

### VPC Endpoint Benefits

- Reduced data transfer costs (no NAT gateway charges for AWS services)
- Improved latency for AWS API calls
- Enhanced security (traffic stays in VPC)

### Ansible Configuration Optimization (Requirement 11)

**Design Rationale**:

- Optimized SSH connection reuse reduces overhead
- YAML callback provides better readability than default output
- Consistent control path prevents conflicts
- Fact caching improves performance for repeated runs

**Configuration Changes**:

```ini
[defaults]
# Requirement 11.3 - Better output readability
stdout_callback = yaml  # Changed from 'skippy'

# Requirement 11.1 - Consistent control path
control_path = ~/.ssh/cp/ssh-%%r@%%h:%%p

# Fact caching for performance
gathering = smart
fact_caching = jsonfile
fact_caching_connection = /tmp/facts_cache
fact_caching_timeout = 7200

[ssh_connection]
# Requirement 11.2 - Connection reuse
ssh_args = -o ControlMaster=auto -o ControlPersist=1200s
pipelining = True
```

**Performance Benefits**:

- Fact caching reduces gather time by ~50% on subsequent runs
- SSH connection reuse (ControlMaster) reduces connection overhead
- Pipelining reduces the number of SSH operations
- YAML callback makes debugging easier without performance impact

**Removed Duplicates** (Requirement 11.5):

- Consolidated duplicate control_path settings
- Removed conflicting SSH configuration options

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

### Pre-commimentationration (Requirement 13)

**Design Rationale**:

- Automated quality checks prevent common errors before commit
- Consistent code formatting across team
- Early detection of syntax and validation errors
- Reduces CI/CD pipeline failures

**Pre-commit Configuration** (.pre-commit-config.yaml):

```yaml
repos:
  - repo: https://github.com/antonbabenko/pre-commit-terraform
    rev: v1.83.5
    hooks:
      - id: terraform_fmt        # Requirement 13.2
      - id: terraform_validate   # Requirement 13.3
      - id: terraform_tflint
      - id: terraform_docs
        args:
          - --hook-config=--path-to-file=README.md
          - --hook-config=--add-to-existing-file=true
          - --hook-config=--create-file-if-not-exist=true

  - repo: https://github.com/ansible/ansible-lint
    rev: v6.22.0
    hooks:
      - id: ansible-lint        # Requirement 13.4
        files: \.(yaml|yml)$
        args: ['-c', '.ansible-lint']
```

**Installation and Usage** (Requirement 13.5):

```bash
# Install pre-commit
pip install pre-commit

# Install hooks
pre-commit install

# Run manually on all files
pre-commit run --all-files
```

**Documentation Location**: README.md includes installation and usage instructions

### Module Documentation (Requirement 12)

**Design Rationale**:

- Terraform-docs format ensures consistency (Requirement 12.5)
- Auto-generated documentation stays in sync with code
- Usage examples provide quick start for new team members
- Input/output documentation aids integration

**Documentation Structure** (Requirements 12.1-12.4):

Each module README.md includes:

1. **Overview**: Module purpose and functionality
2. **Requirements**: Terraform version, provider versions, dependencies
3. **Inputs**: Auto-generated table of variables with descriptions and defaults
4. **Outputs**: Auto-generated table of outputs with descriptions
5. **Usage Example**: Practical example showing module usage

**Example Module README.md**:

```markdown
# Microsoft Services Module

## Overview

This module provisions Windows-based Microsoft services including Active Directory, Exchange, SharePoint, and supporting infrastructure.

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | ~> 5.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| aws_number | Number of instances per service | `map(number)` | `{}` | yes |
| aws_region | AWS region | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| instance_ids | Map of service names to instance IDs |
| security_group_ids | Map of security group IDs |

## Usage Example

\`\`\`hcl
module "microsoft" {
  source = "./microsoft"
  
  aws_number = {
    dc = 2
    exchange = 1
  }
  aws_region = "us-east-1"
  aws_vpc_id = module.global.vpc_id
}
\`\`\`
```

**Documentation Generation**:

```bash
# Generate documentation for all modules
terraform-docs markdown table --output-file README.md --output-mode inject global/
terraform-docs markdown table --output-file README.md --output-mode inject microsoft/
terraform-docs markdown table --output-file README.md --output-mode inject unix/
```

### Code Documentation

- Inline comments for complex logic (Requirement 9.3)
- Variable descriptions (Requirement 5.5)
- Security group rule descriptions (Requirement 18.1-18.5)
- Locals block documentation (Requirement 19.4)

## Code Cleanup and Maintainability (Requirement 9)

### Cleanup Strategy

**Design Rationale**:

- Commented-out code creates confusion and maintenance burden
- Historical context belongs in version control, not comments
- Consistent formatting improves readability
- Clean code follows KISS principle (Requirement 21.2)

**Cleanup Actions**:

1. **Remove Commented-Out Resources** (Requirement 9.1):
   - `main.tf`: Remove commented aws_vpc_dhcp_options block
   - `global/main.tf`: Remove commented providers and s3 modules
   - `microsoft/main.tf`: Remove commented dfs module
   - Document removal reasons in commit messages

2. **Remove Commented-Out Variables** (Requirement 9.2):
   - Audit all `variables.tf` files
   - Remove unused variable declarations
   - Document deprecated variables in MIGRATION.md

3. **Document Historical Context** (Requirement 9.3):
   - Move important historical notes to README.md
   - Document architectural decisions in design.md
   - Use git history for code evolution tracking

4. **Consistent Formatting** (Requirements 9.4, 9.5):
   - Run `terraform fmt -recursive` on all Terraform files
   - Use consistent PowerShell formatting (4-space indentation)
   - Enforce via pre-commit hooks

**Formatting Standards**:

```hcl
# Terraform formatting
- 2-space indentation
- Align equals signs in blocks
- One blank line between resources
- Group related resources together

# PowerShell formatting
- 4-space indentation
- Opening braces on same line
- Consistent parameter formatting
- Use approved verbs (Verb-Noun)
```

**Maintenance Benefits**:

- Easier code review and understanding
- Reduced cognitive load for developers
- Faster onboarding for new team members
- Fewer merge conflicts

## Requirements Traceability Matrix

This section maps each requirement to the design components that address it, ensuring complete coverage.

### Security Requirements

| Requirement | Design Component | Implementation Details |
|-------------|------------------|------------------------|
| 1.1 | Component 1: Security Hardening Layer | Secrets Manager integration in user data scripts |
| 1.2 | Component 1: Security Hardening Layer | Error handling with Windows Event Log |
| 1.3 | Component 1: Security Hardening Layer | Security groups with variable CIDR blocks |
| 1.4 | Component 1: Security Hardening Layer | `admin_cidr_blocks` and `enable_public_admin_access` variables |
| 1.5 | Component 6: IMDSv2 Enforcement | metadata_options block on all instances |
| 2.1-2.3 | Component 1: Security Hardening Layer | RDP, SSH, WinRM rules use `local.admin_cidr_blocks` |
| 2.4 | Component 1: Security Hardening Layer | Description fields on all security group rules |
| 2.5 | Component 1: Security Hardening Layer | Default to RFC1918 private networks |
| 16.1-16.5 | Component 6: IMDSv2 Enforcement | http_tokens="required" on all instances, IMDSv2-compatible scripts |
| 18.1-18.5 | Component 1: Security Hardening Layer | Description fields with consistent formatting |

### Code Quality Requirements

| Requirement | Design Component | Implementation Details |
|-------------|------------------|------------------------|
| 3.1-3.5 | Component 5: Provider Configuration | versions.tf with Terraform >= 1.0, AWS ~> 5.0 |
| 4.1-4.5 | Component 2: Code Deduplication Layer | locals.tf files with common configurations |
| 5.1-5.5 | Component 3: Type Safety and Validation | Explicit types and validation on all variables |
| 9.1-9.5 | Code Cleanup and Maintainability | Remove commented code, consistent formatting |
| 17.1-17.5 | Component 3: Type Safety and Validation | Validation rules with clear error messages |
| 19.1-19.5 | Component 2: Code Deduplication Layer | Organized locals blocks with documentation |
| 21.1 | Component 2: Code Deduplication Layer | DRY principle through locals |
| 21.2-21.5 | Design Decisions and Rationale | KISS principle in all implementations |

### Infrastructure Requirements

| Requirement | Design Component | Implementation Details |
|-------------|------------------|------------------------|
| 7.1-7.5 | Component 5: Provider Configuration | Default tags at provider level |
| 8.1-8.5 | Region Parameterization | Variable-based region in all resources and scripts |
| 10.1-10.5 | Component 4: VPC Endpoint Enhancement | Interface endpoints for SSM, EC2Messages, SSMMessages, Secrets Manager |
| 15.1-15.5 | Terraform State Management | Terraform Cloud backend with encryption and locking |

### Operational Requirements

| Requirement | Design Component | Implementation Details |
|-------------|------------------|------------------------|
| 6.1-6.5 | Component 1: Security Hardening Layer | PowerShell error handling patterns with try-catch |
| 11.1-11.5 | Ansible Configuration Optimization | ansible.cfg with YAML callback, ControlMaster, optimized settings |
| 12.1-12.5 | Module Documentation | README.md files with terraform-docs format |
| 13.1-13.5 | Pre-commit Hook Integration | .pre-commit-config.yaml with terraform and ansible hooks |
| 14.1-14.5 | Component 1: Security Hardening Layer | User data script error handling and validation |
| 20.1-20.5 | Migration Strategy | Backward compatible defaults, moved blocks, migration guide |

## Summary

This design addresses all 21 requirements through 6 main components and supporting infrastructure:

1. **Security Hardening Layer**: Addresses requirements 1, 2, 6, 14, 16, 18
2. **Code Deduplication Layer**: Addresses requirements 4, 19, 21.1
3. **Type Safety and Validation Layer**: Addresses requirements 5, 17
4. **VPC Endpoint Enhancement**: Addresses requirement 10
5. **Provider Configuration Enhancement**: Addresses requirements 3, 7
6. **IMDSv2 Enforcement**: Addresses requirements 1.5, 16

Additional design elements address:

- **Region Parameterization**: Requirement 8
- **Code Cleanup**: Requirement 9
- **Ansible Optimization**: Requirement 11
- **Module Documentation**: Requirement 12
- **Pre-commit Hooks**: Requirement 13
- **State Management**: Requirement 15
- **Backward Compatibility**: Requirement 20
- **Design Principles**: Requirement 21

The design follows established best practices from AWS, Terraform, Ansible, PowerShell, and Windows Server domains, ensuring a robust, maintainable, and secure infrastructure codebase.
