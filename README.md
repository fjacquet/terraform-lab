# terraform-lab

We all need to create a set of VM to perform some labs. Thanks to terraforming, it can be very simple to automate.

Some variables are still hardcoded to simplify writing. Maybe it will go in parameter later

## Project Status

### Architecture

This project uses a **modern, flattened 2-level architecture** that eliminates unnecessary abstraction layers:

- **Old**: root → microsoft/unix → 25+ service modules (3 levels)
- **New**: root → unified service module (2 levels)

**Benefits:**
- 90% code reduction (~2,000 lines → ~300 lines)
- Single source of truth (all configs in `locals.tf`)
- 97% module consolidation (25+ modules → 1 unified module)
- Easier maintenance (edit 1-3 files vs 18-30 files)

See [ARCHITECTURE.md](ARCHITECTURE.md) for detailed architecture documentation.

### Build Status

[![Quality Gate Status](https://sonarcloud.io/api/project_badges/measure?project=fjacquet_terraform-lab&metric=alert_status)](https://sonarcloud.io/dashboard?id=fjacquet_terraform-lab)
[![Build](https://github.com/fjacquet/terraform-lab/actions/workflows/build.yml/badge.svg)](https://github.com/fjacquet/terraform-lab/actions/workflows/build.yml)
[![Known Vulnerabilities](https://snyk.io/test/github/fjacquet/terraform-lab/badge.svg)](https://snyk.io/test/github/fjacquet/terraform-lab)

## Requirements

- **Terraform**: >= 1.0
- **AWS Provider**: ~> 5.0
- **Python**: 3.x with pip
- **Ansible**: Latest version

## Quick Start

### 1. Configure Services

Edit `terraform.tfvars` or `variables.tf` to enable services:

```hcl
aws_number = {
  "guacamole" = 1  # Bastion host (recommended first)
  "adds"      = 2  # Domain Controllers
  "dhcp"      = 1  # DHCP Server
  # ... enable other services as needed
}
```

### 2. Deploy Infrastructure

```bash
# Initialize Terraform
terraform init

# Review planned changes
terraform plan

# Deploy infrastructure
terraform apply
```

### 3. Configure with Ansible

```bash
# Install dependencies
pip3 install -r requirements.txt
ansible-galaxy install -r requirements.yml

# Configure base systems
ansible-parallel playbooks/system/*.yml

# Configure applications
ansible-parallel playbooks/apps/*.yml
```

## Available Services

The project supports **23 services** across Windows and Unix platforms:

### Windows Services (16)
- **adds**: Active Directory Domain Services
- **adfs**: Active Directory Federation Services
- **dhcp**: DHCP Server
- **da**: DirectAccess VPN
- **exchange**: Exchange Server
- **fs**: File Server
- **ipam**: IP Address Management
- **mgmt**: Management Server
- **nps**: Network Policy Server (RADIUS)
- **rdsh**: Remote Desktop Session Host
- **sharepoint**: SharePoint Server
- **sql**: SQL Server
- **simpana**: Commvault Backup
- **sofs**: Scale-Out File Server
- **wac**: Windows Admin Center
- **wds**: Windows Deployment Services
- **wsus**: Windows Server Update Services

### Unix/Linux Services (7)
- **guacamole**: Apache Guacamole (Bastion/Jump Host)
- **glpi**: IT Asset Management
- **vault**: HashiCorp Vault (Secrets Management)
- **nbu**: Veritas NetBackup
- **oracle**: Oracle Database
- **redis**: Redis Cache
- **bsd**: FreeBSD System

All services are configured in a single file (`locals.tf`) and deployed using one unified module (`modules/service/`).

## Configuration

### Security Variables

The project includes security-focused variables to control administrative access to infrastructure:

#### admin_cidr_blocks

Controls which IP addresses/ranges are allowed to access administrative services (RDP, SSH, WinRM):

```hcl
variable "admin_cidr_blocks" {
  description = "CIDR blocks allowed for administrative access"
  type        = list(string)
  default     = ["10.0.0.0/16"]  # Default: VPC CIDR only
}
```

**Best Practices:**
- For production: Restrict to your organization's public IP ranges or VPN endpoints
- For lab environments: Use VPC CIDR (default) or specific trusted networks
- Never use `0.0.0.0/0` in production environments

**Example configurations:**

```hcl
# Corporate office access only
admin_cidr_blocks = ["203.0.113.0/24", "198.51.100.0/24"]

# VPN endpoint access
admin_cidr_blocks = ["10.0.0.0/16", "192.168.1.0/24"]

# Lab environment (VPC only)
admin_cidr_blocks = ["10.0.0.0/16"]
```

#### enable_public_admin_access

Emergency override to allow administrative access from anywhere (not recommended for production):

```hcl
variable "enable_public_admin_access" {
  description = "Allow administrative access from internet"
  type        = bool
  default     = false
}
```

**Warning:** Setting this to `true` allows access from `0.0.0.0/0`. Only use for:
- Temporary troubleshooting in non-production environments
- Initial setup when your IP is unknown
- Always set back to `false` after use

**Security Impact:**
- When `false` (default): Uses `admin_cidr_blocks` for access control
- When `true`: Overrides `admin_cidr_blocks` and allows `0.0.0.0/0`

### Terraform Backend

The project currently uses **local state** storage. The Terraform Cloud remote backend is temporarily disabled due to template provider compatibility issues on Apple Silicon.

If you need to enable remote state in the future, uncomment the backend configuration in `backend.tf`.

### Resource Tagging

All AWS resources are automatically tagged with default tags configured at the provider level:

- **Project**: terraform-lab
- **ManagedBy**: Terraform
- **Environment**: lab
- **Repository**: github.com/fjacquet/terraform-lab

These tags are applied automatically to all resources created by Terraform, enabling better cost tracking, resource management, and compliance.

### IMDSv2 Enforcement

All EC2 instances in this infrastructure are configured to use **Instance Metadata Service Version 2 (IMDSv2)**, which provides enhanced security for accessing instance metadata.

**What is IMDSv2?**

IMDSv2 is a session-oriented method for accessing instance metadata that protects against:
- Server-Side Request Forgery (SSRF) attacks
- Open firewall/NAT/router vulnerabilities
- Open layer 3 firewall vulnerabilities

**Security Benefits:**

1. **Session-based authentication**: Requires a session token obtained via PUT request
2. **Hop limit protection**: Prevents metadata access from containers or forwarded requests
3. **Defense in depth**: Additional security layer even if other protections fail

**Configuration:**

All EC2 instances are configured with:

```hcl
metadata_options {
  http_tokens                 = "required"  # Enforce IMDSv2
  http_put_response_hop_limit = 1           # Prevent forwarding
  http_endpoint               = "enabled"   # Keep metadata service enabled
}
```

**Impact on Scripts:**

User data scripts and applications must use IMDSv2-compatible requests:

```powershell
# PowerShell example - Retrieve IMDSv2 token
$token = Invoke-RestMethod -Uri "http://169.254.169.254/latest/api/token" `
    -Method PUT `
    -Headers @{"X-aws-ec2-metadata-token-ttl-seconds" = "21600"}

# Use token to access metadata
$instanceId = Invoke-RestMethod `
    -Uri "http://169.254.169.254/latest/meta-data/instance-id" `
    -Headers @{"X-aws-ec2-metadata-token" = $token}
```

```bash
# Bash example - Retrieve IMDSv2 token
TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" \
    -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")

# Use token to access metadata
INSTANCE_ID=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" \
    http://169.254.169.254/latest/meta-data/instance-id)
```

**Compatibility:**

All user data scripts in this project have been updated to support IMDSv2. If you add custom scripts, ensure they:
1. Request a session token before accessing metadata
2. Include the token in all metadata requests
3. Handle token expiration (default: 6 hours)

### Shell

To fix winrm on mac set

```bash
no_proxy="*"
```

To speedup terraform set

```bash
TF_CLI_ARGS="-parallelism=50"
TFE_PARALLELISM=50
TF_REGISTRY_CLIENT_TIMEOUT=15
export TF_REGISTRY_CLIENT_TIMEOUT
export TF_CLI_ARGS
export TFE_PARALLELISM
```

### ansible

Be ready to install ansible (pypsrp and boto3 are a must)

```bash
pip3 install -r ./requirements.txt
ansible-galaxy install -r requirements.yml
```

### Pre-commit Hooks

This project uses pre-commit hooks to ensure code quality and consistency. The hooks automatically run Terraform formatting, validation, linting, and Ansible linting before each commit.

#### Installation

1. Install pre-commit:

```bash
pip install pre-commit
```

2. Install the git hook scripts:

```bash
pre-commit install
```

#### Configured Hooks

The following hooks are configured:

- **terraform_fmt**: Automatically formats Terraform files recursively
- **terraform_validate**: Validates Terraform configuration syntax
- **terraform_tflint**: Runs TFLint to catch potential issues
- **ansible-lint**: Lints Ansible playbooks and roles

#### Manual Execution

To run all hooks manually on all files:

```bash
pre-commit run --all-files
```

To run a specific hook:

```bash
pre-commit run terraform_fmt --all-files
pre-commit run ansible-lint --all-files
```

#### Skipping Hooks

If you need to skip hooks for a specific commit (not recommended):

```bash
git commit --no-verify
```

## ssh

To access private network, you can use `.ssh/config` like :

```bash
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
```

where bastion.ez-lab.xyz is a PUBLIC cname to your bastion

An ssh key must be set up, the public key should be declared in variable public_key

## Ressources

### AWS

A valid account must exist for terraform usage

#### EC2

Normally, I use t3.medium except if the application needs more

#### S3

I use an S3 repository named installers-fja, private. Remember to replace the name in your case.

#### Secrets Management

The project uses **AWS Secrets Manager** to securely store and retrieve sensitive credentials. All passwords and secrets are retrieved at runtime from Secrets Manager, eliminating hardcoded credentials in scripts and configuration files.

**Security Benefits:**
- No hardcoded passwords in code or user data scripts
- Centralized secret management and rotation
- Audit trail via CloudTrail
- Encryption at rest with KMS
- Fine-grained IAM access control

**Required Secrets:**

The following secrets must be created in AWS Secrets Manager before deployment:

| Secret Name | Purpose | Format |
|-------------|---------|--------|
| `ez-lab.xyz/ansible/localadmin` | Local administrator password for Windows instances | Plain text password |
| `ezlab/ad/joinuser` | Domain join credentials | JSON: `{"username": "...", "password": "..."}` |
| `ezlab/ad/fjacquet` | Domain user account | Plain text password |
| `ezlab/guacamole/mysqlroot` | Guacamole MySQL root password | Plain text password |
| `ezlab/guacamole/mysqluser` | Guacamole MySQL user password | Plain text password |
| `ezlab/glpi/mysqlroot` | GLPI MySQL root password | Plain text password |
| `ezlab/glpi/mysqluser` | GLPI MySQL user password | Plain text password |
| `ezlab/guacamole/keystore` | Guacamole keystore password | Plain text password |
| `ezlab/guacamole/mail` | Guacamole email configuration | Plain text password |
| `ezlab/sharepoint/sp_farm` | SharePoint farm account | Plain text password |
| `ezlab/sharepoint/sp_services` | SharePoint services account | Plain text password |
| `ezlab/sharepoint/sp_portalAppPool` | SharePoint portal app pool account | Plain text password |
| `ezlab/sharepoint/sp_profilesAppPool` | SharePoint profiles app pool account | Plain text password |
| `ezlab/sharepoint/sp_searchService` | SharePoint search service account | Plain text password |
| `ezlab/sharepoint/sp_cacheSuperUser` | SharePoint cache super user | Plain text password |
| `ezlab/sharepoint/sp_cacheSuperReader` | SharePoint cache super reader | Plain text password |
| `ezlab/sql/svc-sql` | SQL Server service account | Plain text password |
| `ezlab/pki/svc-ndes` | NDES service account | Plain text password |

**Creating Secrets:**

Use the AWS CLI or Console to create secrets:

```bash
# Using AWS CLI
aws secretsmanager create-secret \
    --name "ez-lab.xyz/ansible/localadmin" \
    --description "Local administrator password" \
    --secret-string "YourSecurePassword123!"

# Generate random password
aws secretsmanager create-secret \
    --name "ezlab/guacamole/mysqlroot" \
    --description "Guacamole MySQL root password" \
    --secret-string "$(openssl rand -base64 32)"

# JSON format for credentials with username
aws secretsmanager create-secret \
    --name "ezlab/ad/joinuser" \
    --description "Domain join credentials" \
    --secret-string '{"username":"domain-join-user","password":"SecurePassword123!"}'
```

**IAM Permissions:**

EC2 instances require IAM permissions to retrieve secrets:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret"
      ],
      "Resource": [
        "arn:aws:secretsmanager:*:*:secret:ez-lab.xyz/*",
        "arn:aws:secretsmanager:*:*:secret:ezlab/*"
      ]
    }
  ]
}
```

**Usage in Scripts:**

PowerShell scripts automatically retrieve secrets using the AWS PowerShell module:

```powershell
# Retrieve secret with error handling
$password = Get-SECSecretValue -SecretId "ez-lab.xyz/ansible/localadmin" -Region $region -ErrorAction Stop
```

**VPC Endpoints:**

For enhanced security and reduced costs, the infrastructure includes a VPC endpoint for Secrets Manager, allowing instances in private subnets to access secrets without internet connectivity.

## Deployment Workflow

### 1. Enable Services

Edit the `aws_number` variable in `terraform.tfvars` or `variables.tf`:

```hcl
variable "aws_number" {
  default = {
    "guacamole" = 1  # Start with bastion
    "adds"      = 2  # Then domain controllers
    "dhcp"      = 1  # Then infrastructure services
    # ... enable others as needed
  }
}
```

### 2. Deploy Infrastructure

```bash
# Validate configuration
terraform validate

# Review changes
terraform plan

# Deploy
terraform apply

# View deployed services
terraform output deployed_services
```

### 3. Configure with Ansible

```bash
# Configure base operating systems
ansible-parallel playbooks/system/configure-windows.yml
ansible-parallel playbooks/system/configure-linux.yml

# Configure applications
ansible-parallel playbooks/apps/configure_pdc.yml
ansible-parallel playbooks/apps/configure_dhcp.yml
# ... run other app playbooks as needed
```

## Build Order and Dependencies

### Recommended Deployment Order

1. **Guacamole** (bastion host) - Deploy first for secure access
2. **Domain Controllers** (adds) - Required for Windows domain services
3. **Infrastructure Services** (dhcp, dns, ipam) - Core network services
4. **Application Services** (exchange, sharepoint, sql) - Business applications
5. **Management Services** (wac, mgmt) - Administrative tools

### Service Dependencies

- **Windows Services**: Most require domain controllers (adds) to be deployed first
- **Guacamole**: Should be deployed first as it provides bastion/jump host access
- **Exchange/SharePoint**: Require SQL Server and domain controllers
- **PKI Services**: Require domain controllers and specific deployment order (RCA → ICA → CRL → NDES)

## Adding or Modifying Services

### To Add a New Service

1. **Add configuration to `locals.tf`**:
```hcl
locals {
  windows_services = {
    # ... existing services
    
    mynewservice = {
      instance_type    = "t3.medium"
      subnet_type      = "back"
      os_type          = "windows"
      ami_type         = "windows2022"
      user_data        = "user_data/config-win.ps1"
      root_volume_size = 30
      has_public_dns   = false
      creates_sg       = true
    }
  }
}
```

2. **Add to `variables.tf`**:
```hcl
variable "aws_number" {
  default = {
    # ... existing services
    "mynewservice" = 0
  }
}
```

3. **Deploy**:
```bash
terraform plan
terraform apply
```

That's it! No need to create new modules or update multiple files.

### To Modify a Service

Simply edit the service configuration in `locals.tf` and run `terraform apply`. All service configurations are in one place!

## Project Structure

```
terraform-lab/
├── main.tf                    # Root module with unified service deployment
├── locals.tf                  # ALL service configurations (single source of truth)
├── variables.tf               # Input variables
├── outputs.tf                 # Output values
├── backend.tf                 # Terraform backend configuration
├── versions.tf                # Provider version constraints
│
├── modules/
│   └── service/               # UNIFIED service module (Windows + Unix)
│       ├── main.tf            # Generic instance, SG, and DNS resources
│       ├── variables.tf       # Module inputs
│       ├── outputs.tf         # Module outputs
│       └── README.md          # Module documentation
│
├── global/                    # Global infrastructure
│   ├── vpc/                   # VPC, subnets, routing
│   ├── iam/                   # IAM roles and policies
│   ├── route53/               # DNS zones
│   └── dynamodb/              # State locking
│
├── user_data/                 # Bootstrap scripts
│   ├── config-win.ps1         # Windows initialization
│   └── config-linux.sh        # Linux initialization
│
├── playbooks/                 # Ansible configuration
│   ├── system/                # Base OS configuration
│   └── apps/                  # Application configuration
│
├── inventory/                 # Ansible dynamic inventory
│   └── aws_ec2.yaml           # AWS EC2 plugin configuration
│
└── docs/                      # Documentation
    ├── ARCHITECTURE.md        # Architecture details
    ├── TERRAFORM-DOCS.md      # Terraform documentation
    └── DEPLOYMENT-STATUS.md   # Deployment guide
```
