# Configuration Guide

Complete configuration reference for terraform-lab infrastructure.

## Table of Contents

- [Security Configuration](#security-configuration)
- [Service Configuration](#service-configuration)
- [AWS Resources](#aws-resources)
- [Terraform Backend](#terraform-backend)
- [Environment Setup](#environment-setup)
- [SSH Configuration](#ssh-configuration)
- [Pre-commit Hooks](#pre-commit-hooks)

---

## Security Configuration

### Admin Access Control

#### admin_cidr_blocks

Controls which IP addresses/ranges can access administrative services (RDP, SSH, WinRM).

```hcl
variable "admin_cidr_blocks" {
  description = "CIDR blocks allowed for administrative access"
  type        = list(string)
  default     = ["10.0.0.0/16"]  # VPC CIDR only (secure default)
}
```

**Examples:**

```hcl
# Corporate office only
admin_cidr_blocks = ["203.0.113.0/24", "198.51.100.0/24"]

# VPN + VPC access
admin_cidr_blocks = ["10.0.0.0/16", "192.168.1.0/24"]

# Lab environment (VPC only) - RECOMMENDED
admin_cidr_blocks = ["10.0.0.0/16"]
```

**Best Practices:**
- ✅ Use VPC CIDR for lab environments
- ✅ Restrict to specific IP ranges for production
- ❌ Never use `0.0.0.0/0` in production

#### enable_public_admin_access

Emergency override for public administrative access.

```hcl
variable "enable_public_admin_access" {
  description = "Allow administrative access from internet"
  type        = bool
  default     = false  # Secure default
}
```

**⚠️ Warning:** Setting to `true` allows access from `0.0.0.0/0`

**When to use:**
- ✅ Temporary troubleshooting in non-production
- ✅ Initial setup when your IP is unknown
- ❌ Never in production environments

**Security Impact:**
- `false` (default): Uses `admin_cidr_blocks` for access control
- `true`: Overrides `admin_cidr_blocks` and allows `0.0.0.0/0`

### IMDSv2 Enforcement

All EC2 instances enforce **Instance Metadata Service Version 2 (IMDSv2)** for enhanced security.

**What is IMDSv2?**

Session-oriented metadata access that protects against:
- Server-Side Request Forgery (SSRF) attacks
- Open firewall/NAT/router vulnerabilities
- Layer 3 firewall vulnerabilities

**Configuration:**

```hcl
metadata_options {
  http_tokens                 = "required"  # Enforce IMDSv2
  http_put_response_hop_limit = 1           # Prevent forwarding
  http_endpoint               = "enabled"   # Keep metadata enabled
}
```

**Using IMDSv2 in Scripts:**

PowerShell:
```powershell
# Get token
$token = Invoke-RestMethod -Uri "http://169.254.169.254/latest/api/token" `
    -Method PUT `
    -Headers @{"X-aws-ec2-metadata-token-ttl-seconds" = "21600"}

# Use token
$instanceId = Invoke-RestMethod `
    -Uri "http://169.254.169.254/latest/meta-data/instance-id" `
    -Headers @{"X-aws-ec2-metadata-token" = $token}
```

Bash:
```bash
# Get token
TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" \
    -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")

# Use token
INSTANCE_ID=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" \
    http://169.254.169.254/latest/meta-data/instance-id)
```

**Requirements:**
1. Request session token before accessing metadata
2. Include token in all metadata requests
3. Handle token expiration (default: 6 hours)

### Resource Tagging

All resources automatically tagged with:

```hcl
default_tags {
  tags = {
    Project     = "terraform-lab"
    ManagedBy   = "Terraform"
    Environment = "lab"
    Repository  = "github.com/fjacquet/terraform-lab"
  }
}
```

**Benefits:**
- Cost tracking and allocation
- Resource management and filtering
- Compliance and governance
- Automated operations

---

## Service Configuration

### Enabling Services

Edit `terraform.tfvars` or `variables.tf`:

```hcl
variable "aws_number" {
  description = "Number of instances per service (0-10)"
  type        = map(number)
  
  default = {
    "guacamole" = 1  # Bastion host
    "adds"      = 2  # Domain controllers
    "dhcp"      = 1  # DHCP server
    "sql"       = 1  # SQL Server
    # ... set others as needed
  }
}
```

**Service Count:**
- `0` = Service disabled
- `1-10` = Number of instances to deploy

### Service Dependencies

**Deployment Order:**

1. **Guacamole** - Bastion host (deploy first)
2. **Domain Controllers (adds)** - Required for Windows services
3. **Infrastructure** - DHCP, DNS, IPAM
4. **Applications** - Exchange, SharePoint, SQL
5. **Management** - WAC, management servers

**Dependencies:**
- Windows services → Require domain controllers
- Exchange/SharePoint → Require SQL Server + domain
- PKI services → Require domain + specific order

### Available Services

**Windows Services (16):**
- `adds` - Active Directory Domain Services
- `adfs` - AD Federation Services
- `dhcp` - DHCP Server
- `da` - DirectAccess VPN
- `exchange` - Exchange Server
- `fs` - File Server
- `ipam` - IP Address Management
- `mgmt` - Management Server
- `nps` - Network Policy Server (RADIUS)
- `rdsh` - Remote Desktop Session Host
- `sharepoint` - SharePoint Server
- `sql` - SQL Server
- `simpana` - Commvault Backup
- `sofs` - Scale-Out File Server
- `wac` - Windows Admin Center
- `wds` - Windows Deployment Services
- `wsus` - Windows Update Services

**Unix/Linux Services (7):**
- `guacamole` - Apache Guacamole (Bastion)
- `glpi` - IT Asset Management
- `vault` - HashiCorp Vault
- `nbu` - Veritas NetBackup
- `oracle` - Oracle Database
- `redis` - Redis Cache
- `bsd` - FreeBSD System

---

## AWS Resources

### Required AWS Resources

**EC2:**
- Instance types: Primarily t3.medium
- AMIs: Windows Server 2022, SQL Server 2019, Debian 12, RHEL 9, FreeBSD 14
- EBS volumes: Encrypted by default

**Networking:**
- VPC with multiple subnet types
- Internet Gateway
- NAT Gateway (optional)
- VPC Endpoints (SSM, Secrets Manager, EC2Messages)

**IAM:**
- Instance profiles for EC2
- Roles for service access
- Policies for Secrets Manager, SSM

**Route53:**
- Private hosted zone
- Public hosted zone (optional)

**Secrets Manager:**
- Service credentials
- Domain join credentials
- Application passwords

### S3 Bucket

The project references an S3 bucket for installers:

```hcl
# Update to your bucket name
bucket_name = "installers-fja"  # Change this
```

**Required:** Create your own S3 bucket and update references in:
- User data scripts
- Ansible playbooks
- Terraform variables

### Secrets Manager

**Required Secrets:**

| Secret Name | Purpose | Format |
|-------------|---------|--------|
| `ez-lab.xyz/ansible/localadmin` | Windows local admin | Plain text |
| `ezlab/ad/joinuser` | Domain join | JSON: `{"username":"...","password":"..."}` |
| `ezlab/guacamole/mysqlroot` | Guacamole MySQL root | Plain text |
| `ezlab/sql/svc-sql` | SQL Server service | Plain text |
| ... | See full list in README | ... |

**Creating Secrets:**

```bash
# Simple secret
aws secretsmanager create-secret \
    --name "ez-lab.xyz/ansible/localadmin" \
    --secret-string "YourSecurePassword123!"

# Generate random password
aws secretsmanager create-secret \
    --name "ezlab/guacamole/mysqlroot" \
    --secret-string "$(openssl rand -base64 32)"

# JSON format
aws secretsmanager create-secret \
    --name "ezlab/ad/joinuser" \
    --secret-string '{"username":"join-user","password":"SecurePass123!"}'
```

**IAM Permissions:**

```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Action": [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret"
    ],
    "Resource": [
      "arn:aws:secretsmanager:*:*:secret:ez-lab.xyz/*",
      "arn:aws:secretsmanager:*:*:secret:ezlab/*"
    ]
  }]
}
```

---

## Terraform Backend

### Local State (Default)

Currently using local state storage:

```hcl
# backend.tf
# Remote backend commented out
```

**Pros:**
- Simple setup
- No external dependencies
- Works on Apple Silicon

**Cons:**
- No state locking
- No collaboration
- Manual backup required

### Terraform Cloud (Optional)

To enable remote state, uncomment in `backend.tf`:

```hcl
terraform {
  backend "remote" {
    organization = "your-org"
    
    workspaces {
      name = "terraform-lab"
    }
  }
}
```

**Benefits:**
- State locking
- Team collaboration
- State versioning
- Remote execution

---

## Environment Setup

### Terraform Performance

```bash
# Speed up Terraform operations
export TF_CLI_ARGS="-parallelism=50"
export TFE_PARALLELISM=50
export TF_REGISTRY_CLIENT_TIMEOUT=15
```

Add to `~/.bashrc` or `~/.zshrc` for persistence.

### WinRM on macOS

```bash
# Fix WinRM connectivity issues
export no_proxy="*"
```

### Python Dependencies

```bash
# Install Ansible and dependencies
pip3 install -r requirements.txt

# Install Ansible collections
ansible-galaxy install -r requirements.yml
```

**Key Dependencies:**
- `ansible` - Automation platform
- `boto3` - AWS SDK for Python
- `pypsrp` - PowerShell remoting
- `pywinrm` - Windows remote management

---

## SSH Configuration

### Bastion Access

Configure SSH to use Guacamole as bastion:

```bash
# ~/.ssh/config
Host bastion
    Hostname bastion.ez-lab.xyz
    IdentityFile ~/.ssh/aws
    User admin
    ControlMaster auto
    ControlPath ~/.ansible/cp/ssh-%r
    ControlPersist 5m

Host *.compute.internal
    ProxyCommand ssh -C -W %h:%p bastion
    IdentityFile ~/.ssh/aws
    User admin

Host *.compute.amazonaws.com
    ProxyCommand ssh -C -W %h:%p bastion
    IdentityFile ~/.ssh/aws
    User admin
```

**Requirements:**
- SSH key pair created in AWS
- Public key configured in `variables.tf`
- Guacamole deployed and accessible

### SSH Key Setup

```bash
# Generate SSH key
ssh-keygen -t rsa -b 4096 -f ~/.ssh/aws

# Add public key to variables.tf
variable "public_key" {
  default = "ssh-rsa AAAA... your-key-here"
}
```

---

## Pre-commit Hooks

### Installation

```bash
# Install pre-commit
pip install pre-commit

# Install hooks
pre-commit install
```

### Configured Hooks

- `terraform_fmt` - Format Terraform files
- `terraform_validate` - Validate syntax
- `terraform_tflint` - Lint Terraform code
- `ansible-lint` - Lint Ansible playbooks

### Usage

```bash
# Run all hooks
pre-commit run --all-files

# Run specific hook
pre-commit run terraform_fmt --all-files

# Skip hooks (not recommended)
git commit --no-verify
```

### Benefits

- Consistent code formatting
- Early error detection
- Enforced best practices
- Automated quality checks

---

## Additional Configuration

### Region Configuration

```hcl
variable "aws_region" {
  default = "eu-west-1"
}

variable "azs" {
  default = ["eu-west-1a"]
}
```

**Multi-AZ Deployment:**

```hcl
azs = [
  "eu-west-1a",
  "eu-west-1b",
  "eu-west-1c"
]
```

### DNS Configuration

```hcl
variable "dns_suffix" {
  default = "ez-lab.xyz"
}

variable "public_dns_id" {
  default = "Z07150253A0MNSTGYQG5P"  # Your Route53 zone ID
}
```

### Network Configuration

CIDR blocks are automatically calculated based on:
- VPC CIDR: `10.0.0.0/16`
- Subnet types: web, back, mgmt, exchange, backup, sql
- Availability zones

See `locals.tf` for CIDR block calculations.

---

## Troubleshooting

### Common Issues

**Issue: Cannot connect via RDP/SSH**
- Check `admin_cidr_blocks` includes your IP
- Verify security groups in AWS Console
- Ensure `enable_public_admin_access` is set correctly

**Issue: Secrets Manager access denied**
- Verify IAM instance profile permissions
- Check VPC endpoint for Secrets Manager
- Verify secret names match exactly

**Issue: Terraform performance slow**
- Set parallelism environment variables
- Use VPC endpoints to reduce latency
- Check network connectivity

**Issue: WinRM not working on macOS**
- Set `no_proxy="*"` environment variable
- Verify Ansible configuration
- Check Windows firewall rules

---

## Next Steps

- Review [ARCHITECTURE.md](../ARCHITECTURE.md) for architecture details
- See [DEPLOYMENT-STATUS.md](DEPLOYMENT-STATUS.md) for deployment guide
- Check [SECURITY.md](SECURITY.md) for security best practices
- Read [modules/service/README.md](../modules/service/README.md) for module documentation

---

**Last Updated:** 2024  
**Terraform Version:** >= 1.0  
**AWS Provider:** ~> 5.0
