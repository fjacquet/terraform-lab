# Unix/Linux Services Module

## Overview

The unix module provisions Linux and Unix-based services in AWS. It includes bastion hosts (Guacamole), IT asset management (GLPI), secrets management (Vault), backup services (NetBackup), database servers (Oracle), caching (Redis), and BSD systems. All modules follow a consistent pattern with common Unix configuration and service-specific customization.

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | ~> 5.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| aws_iip_assumerole_name | IAM instance profile name for EC2 instances | `string` | n/a | yes |
| aws_key_pair_auth_id | AWS key pair ID for SSH access | `string` | n/a | yes |
| aws_region | AWS region for infrastructure deployment | `string` | n/a | yes |
| aws_sg_simpana_client_id | Simpana/Commvault client security group ID | `string` | n/a | yes |
| dns_zone_id | Route 53 private hosted zone ID | `string` | n/a | yes |
| dns_public_zone_id | Route 53 public hosted zone ID | `string` | n/a | yes |
| aws_vpc_id | VPC ID where resources will be created | `string` | n/a | yes |
| vpc_cidr | VPC CIDR block | `string` | n/a | yes |
| azs | List of AWS availability zones | `list(string)` | n/a | yes |
| dns_suffix | DNS domain name suffix | `string` | n/a | yes |
| admin_cidr_blocks | CIDR blocks allowed for administrative access (SSH) | `list(string)` | n/a | yes |
| cidr_blocks | Computed CIDR blocks for all subnet types | `map(list(string))` | n/a | yes |
| aws_subnet_web_id | List of web tier subnet IDs | `list(string)` | n/a | yes |
| aws_subnet_back_id | List of backend subnet IDs | `list(string)` | n/a | yes |
| aws_subnet_backup_id | List of backup subnet IDs | `list(string)` | n/a | yes |
| aws_subnet_mgmt_id | List of management subnet IDs | `list(string)` | n/a | yes |
| aws_number | Map of instance counts per service type | `map(string)` | n/a | yes |
| aws_disks_size | Map of disk sizes for services requiring additional storage | `map(string)` | n/a | yes |
| cidrbyte | Map of third octet values for subnet CIDR blocks | `map(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| aws_sg_ssh_id | SSH security group ID |
| aws_sg_nbuclient_ids | NetBackup client security group IDs |

## Service Modules

### Guacamole (Bastion Host)

Provisions Apache Guacamole servers for web-based remote access.

**Key Features:**

- Web-based remote desktop gateway
- Clientless remote access (RDP, SSH, VNC)
- Multi-protocol support
- Management tier deployment with public access
- Serves as bastion/jump host for the environment

**Operating System:** Debian 12

**Instance Count Variable:** `aws_number["guacamole"]`

**Typical Use Case:** Primary entry point for accessing lab infrastructure

### GLPI (IT Asset Management)

Provisions GLPI servers for IT asset and service management.

**Key Features:**

- IT asset management
- Help desk ticketing
- Inventory management
- FusionInventory integration
- Web-based interface

**Operating System:** Debian 12

**Instance Count Variable:** `aws_number["glpi"]`

**Typical Use Case:** Track and manage lab infrastructure assets

### HashiCorp Vault

Provisions HashiCorp Vault servers for secrets management.

**Key Features:**

- Secrets management
- Dynamic secrets
- Encryption as a service
- PKI management
- Secure credential storage

**Operating System:** Debian 12

**Instance Count Variable:** `aws_number["vault"]`

**Typical Use Case:** Centralized secrets management for applications

### NetBackup (NBU)

Provisions Veritas NetBackup servers for enterprise backup.

**Key Features:**

- Enterprise backup and recovery
- Multi-platform support
- Deduplication
- Additional EBS volumes for backup storage
- Backup tier deployment

**Operating System:** RHEL 9

**Instance Count Variable:** `aws_number["nbu"]`

**Disk Configuration:**

- `aws_disks_size["nbu_backups"]`: Backup storage volume size
- `aws_disks_size["nbu_openv"]`: OpenVPN volume size

**Typical Use Case:** Enterprise-grade backup solution for lab environment

### Oracle Database

Provisions Oracle Database servers.

**Key Features:**

- Oracle Database
- Enterprise database services
- Integration with NetBackup for backups
- Backend tier deployment

**Operating System:** RHEL 9

**Instance Count Variable:** `aws_number["oracle"]`

**Typical Use Case:** Enterprise database workloads

### Redis

Provisions Redis servers for caching and data structures.

**Key Features:**

- In-memory data store
- Caching layer
- Pub/sub messaging
- Data structures server

**Operating System:** Debian 12

**Instance Count Variable:** `aws_number["redis"]`

**Typical Use Case:** Application caching and session storage

### BSD

Provisions FreeBSD servers for Unix workloads.

**Key Features:**

- FreeBSD 13 operating system
- Unix compatibility
- ZFS filesystem support
- Backend tier deployment

**Operating System:** FreeBSD 13

**Instance Count Variable:** `aws_number["bsd"]`

**Typical Use Case:** Unix-specific applications and testing

## Usage Example

```hcl
module "unix" {
  source = "./unix"
  
  # Common configuration
  aws_iip_assumerole_name = module.global.aws_iip_assumerole
  aws_key_pair_auth_id    = aws_key_pair.auth.id
  aws_region              = "us-east-1"
  aws_vpc_id              = module.global.aws_vpc_id
  vpc_cidr                = module.global.vpc_cidr
  azs                     = ["us-east-1a", "us-east-1b", "us-east-1c"]
  dns_zone_id             = module.global.dns_zone_id
  dns_public_zone_id      = module.global.dns_public_zone_id
  dns_suffix              = "ez-lab.xyz"
  
  # Security configuration
  admin_cidr_blocks       = ["10.0.0.0/16"]
  
  # Subnet configuration
  aws_subnet_web_id       = module.global.aws_subnet_web_id
  aws_subnet_back_id      = module.global.aws_subnet_back_id
  aws_subnet_backup_id    = module.global.aws_subnet_backup_id
  aws_subnet_mgmt_id      = module.global.aws_subnet_mgmt_id
  
  # CIDR blocks
  cidr_blocks             = local.cidr_blocks
  cidrbyte                = var.cidrbyte
  
  # Backup integration
  aws_sg_simpana_client_id = module.microsoft.aws_sg_simpana_client_id
  
  # Instance counts
  aws_number = {
    guacamole = 1
    glpi      = 0
    vault     = 0
    nbu       = 0
    oracle    = 0
    redis     = 0
    bsd       = 0
  }
  
  # Disk sizes for services requiring additional storage
  aws_disks_size = {
    nbu_backups = "500"  # GB
    nbu_openv   = "100"  # GB
  }
}
```

## Security Groups

### SSH Security Group

Provides administrative access to Unix/Linux servers.

**Ingress Rules:**

- SSH (22/tcp) from admin CIDR blocks
- Cockpit web console (9090/tcp) from VPC

**Egress Rules:**

- All traffic (IPv4 and IPv6)

### Service-Specific Security Groups

Each service module creates its own security group for service-specific traffic:

- **Guacamole**: HTTP/HTTPS (80/tcp, 443/tcp) from internet
- **GLPI**: HTTP/HTTPS (80/tcp, 443/tcp) from VPC
- **Vault**: Vault API (8200/tcp) from VPC
- **NetBackup**: NBU ports (1556/tcp, 13724/tcp, etc.) from VPC
- **Oracle**: Oracle Database (1521/tcp) from VPC
- **Redis**: Redis (6379/tcp) from VPC

## Common Configuration Pattern

All Unix service modules use a common configuration pattern defined in `locals.tf`:

```hcl
locals {
  # Common Unix configuration shared across all modules
  common_unix_config = {
    aws_iip_assumerole_name = var.aws_iip_assumerole_name
    aws_key_pair_auth_id    = var.aws_key_pair_auth_id
    aws_region              = var.aws_region
    aws_vpc_id              = var.aws_vpc_id
    azs                     = var.azs
    dns_zone_id             = var.dns_zone_id
    dns_suffix              = var.dns_suffix
    dns_public_zone_id      = var.dns_public_zone_id
  }
  
  # Common security groups for Unix servers
  common_unix_sg_ids = flatten([
    aws_security_group.ssh.id,
    module.simpana.aws_sg_client_id,
    module.nbu.aws_sg_client_ids,
  ])
}
```

## AMI Selection

- **Debian 12**: Default for most services (Guacamole, GLPI, Vault, Redis)
- **RHEL 9**: Used for NetBackup and Oracle
- **FreeBSD 13**: Used for BSD module
- **Amazon Linux 2023**: Available as alternative

## Deployment Architecture

```
Unix/Linux Services
├── Management Tier (Public)
│   └── Guacamole (Bastion/Jump Host)
├── Backend Tier (Private)
│   ├── GLPI (Asset Management)
│   ├── Vault (Secrets Management)
│   ├── Oracle (Database)
│   ├── Redis (Cache)
│   └── BSD (Unix Systems)
└── Backup Tier (Private)
    └── NetBackup (Backup Server)
```

## Integration Points

### With Microsoft Module

- NetBackup client security groups for Windows backup
- Simpana/Commvault client security groups for Windows backup
- Cross-platform backup and monitoring

### With Global Module

- VPC and subnet integration
- DNS zone integration
- IAM role integration

### Ansible Configuration

All Unix/Linux systems are configured using Ansible:

- **System Playbooks**: `playbooks/system/configure-linux.yml`
- **Application Playbooks**: `playbooks/apps/configure_*.yml`
- **Roles**: Located in `roles/` directory
  - `debian_*`: Debian-specific roles
  - `rhel_*`: RHEL-specific roles
  - `linux_*`: Generic Linux roles

## Notes

- All Linux instances enforce IMDSv2 for enhanced security
- Instances are deployed across multiple availability zones for high availability
- Security groups follow the principle of least privilege
- All resources are tagged for cost allocation and management
- Guacamole should be deployed first as it serves as the bastion host
- User data scripts handle initial system configuration
- Ansible playbooks are used for post-deployment configuration
- The module uses locals to reduce code duplication and improve maintainability
- NetBackup requires additional EBS volumes for backup storage
- Oracle and NetBackup use RHEL 9 for enterprise support
- Debian 12 is the default for most services due to stability and package availability
