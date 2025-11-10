# Microsoft Windows Services Module

## Overview

The microsoft module provisions Windows-based enterprise services in AWS. It includes Active Directory, Exchange, SharePoint, SQL Server, PKI infrastructure, and various network services. All modules follow a consistent pattern with common Windows configuration and service-specific customization.

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | ~> 5.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| aws_iip_assumerole_name | IAM instance profile name for EC2 instances | `string` | n/a | yes |
| aws_key_pair_auth_id | AWS key pair ID for SSH/RDP access | `string` | n/a | yes |
| aws_region | AWS region for infrastructure deployment | `string` | n/a | yes |
| aws_sg_nbuclient_ids | NetBackup client security group IDs | `string` | n/a | yes |
| dns_zone_id | Route 53 private hosted zone ID | `string` | n/a | yes |
| dns_public_zone_id | Route 53 public hosted zone ID | `string` | n/a | yes |
| aws_vpc_id | VPC ID where resources will be created | `string` | n/a | yes |
| vpc_cidr | VPC CIDR block | `string` | n/a | yes |
| azs | List of AWS availability zones | `list(string)` | n/a | yes |
| dns_suffix | DNS domain name suffix | `string` | n/a | yes |
| admin_cidr_blocks | CIDR blocks allowed for administrative access (RDP, SSH, WinRM) | `list(string)` | n/a | yes |
| cidr_blocks | Computed CIDR blocks for all subnet types | `map(list(string))` | n/a | yes |
| aws_subnet_back_id | List of backend subnet IDs | `list(string)` | n/a | yes |
| aws_subnet_backup_id | List of backup subnet IDs | `list(string)` | n/a | yes |
| aws_subnet_exchange_id | List of Exchange subnet IDs | `list(string)` | n/a | yes |
| aws_subnet_mgmt_id | List of management subnet IDs | `list(string)` | n/a | yes |
| aws_subnet_web_id | List of web tier subnet IDs | `list(string)` | n/a | yes |
| aws_number | Map of instance counts per service type | `map(string)` | n/a | yes |
| cidrbyte | Map of third octet values for subnet CIDR blocks | `map(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| aws_sg_dc_id | Active Directory domain controller security group ID |
| aws_sg_domain_member_id | Domain member security group ID |
| aws_sg_rdp_id | RDP security group ID |

## Service Modules

### Active Directory Domain Services (ADDS)

Provisions Windows Server domain controllers for Active Directory.

**Key Features:**

- Primary and additional domain controllers
- DNS integration
- Domain member security group management
- Multi-AZ deployment support

**Instance Count Variable:** `aws_number["dc"]`

### Active Directory Certificate Services (ADCS)

Provisions PKI infrastructure including Root CA, Issuing CA, CRL, and NDES servers.

**Key Features:**

- Root Certificate Authority (RCA)
- Issuing Certificate Authority (ICA)
- Certificate Revocation List (CRL) server
- Network Device Enrollment Service (NDES)

**Instance Count Variables:**

- `aws_number["pki-rca"]`
- `aws_number["pki-ica"]`
- `aws_number["pki-crl"]`
- `aws_number["pki-ndes"]`

### Active Directory Federation Services (ADFS)

Provisions ADFS servers for single sign-on and federation.

**Key Features:**

- Federation services
- Claims-based authentication
- Web tier deployment

**Instance Count Variable:** `aws_number["adfs"]`

### DHCP Server

Provisions Windows DHCP servers for IP address management.

**Key Features:**

- DHCP service
- Scope management
- Integration with Active Directory

**Instance Count Variable:** `aws_number["dhcp"]`

### DirectAccess (DA)

Provisions DirectAccess servers for remote access VPN.

**Key Features:**

- Always-on VPN connectivity
- Seamless remote access
- Management tier deployment

**Instance Count Variable:** `aws_number["da"]`

### Exchange Server

Provisions Microsoft Exchange servers for email and collaboration.

**Key Features:**

- Email services
- Mailbox management
- Dedicated Exchange subnet deployment

**Instance Count Variable:** `aws_number["exchange"]`

### File Server (FS)

Provisions Windows file servers with SMB/CIFS shares.

**Key Features:**

- File sharing services
- DFS support
- Shadow copies
- Domain member integration

**Instance Count Variable:** `aws_number["fs"]`

### IP Address Management (IPAM)

Provisions Windows IPAM servers for IP address tracking.

**Key Features:**

- IP address management
- DHCP and DNS integration
- Address space planning

**Instance Count Variable:** `aws_number["ipam"]`

### Management Server (MGMT)

Provisions management servers for administrative tasks.

**Key Features:**

- Administrative tools
- Management tier deployment
- Public DNS integration

**Instance Count Variable:** `aws_number["mgmt"]`

### Network Policy Server (NPS)

Provisions NPS servers for RADIUS authentication.

**Key Features:**

- RADIUS authentication
- Network access policies
- 802.1X support

**Instance Count Variable:** `aws_number["nps"]`

### Remote Desktop Session Host (RDSH)

Provisions RDS session hosts for remote desktop services.

**Key Features:**

- Remote desktop services
- Session hosting
- Application publishing

**Instance Count Variable:** `aws_number["rdsh"]`

### SharePoint Server

Provisions Microsoft SharePoint servers for collaboration.

**Key Features:**

- SharePoint services
- Document management
- Web tier deployment

**Instance Count Variable:** `aws_number["sharepoint"]`

### SQL Server

Provisions Microsoft SQL Server instances.

**Key Features:**

- SQL Server 2019
- Database services
- Dedicated SQL subnet deployment
- Uses SQL Server AMI

**Instance Count Variable:** `aws_number["sql"]`

### Simpana/Commvault

Provisions Commvault backup servers.

**Key Features:**

- Backup and recovery
- Data protection
- Backup tier deployment

**Instance Count Variable:** `aws_number["simpana"]`

### Scale-Out File Server (SOFS)

Provisions Windows Scale-Out File Servers for clustered storage.

**Key Features:**

- Clustered file services
- High availability
- SMB 3.0 support

**Instance Count Variable:** `aws_number["sofs"]`

### Windows Admin Center (WAC)

Provisions Windows Admin Center servers for web-based management.

**Key Features:**

- Web-based management interface
- Server administration
- Monitoring and diagnostics

**Instance Count Variable:** `aws_number["wac"]`

### Windows Deployment Services (WDS)

Provisions WDS servers for OS deployment.

**Key Features:**

- Network-based OS installation
- PXE boot support
- Image management

**Instance Count Variable:** `aws_number["wds"]`

### Windows Server Update Services (WSUS)

Provisions WSUS servers for Windows update management.

**Key Features:**

- Update management
- Patch deployment
- Approval workflows

**Instance Count Variable:** `aws_number["wsus"]`

## Usage Example

```hcl
module "microsoft" {
  source = "./microsoft"
  
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
  aws_subnet_back_id      = module.global.aws_subnet_back_id
  aws_subnet_backup_id    = module.global.aws_subnet_backup_id
  aws_subnet_exchange_id  = module.global.aws_subnet_exchange_id
  aws_subnet_mgmt_id      = module.global.aws_subnet_mgmt_id
  aws_subnet_web_id       = module.global.aws_subnet_web_id
  
  # CIDR blocks
  cidr_blocks             = local.cidr_blocks
  cidrbyte                = var.cidrbyte
  
  # Backup integration
  aws_sg_nbuclient_ids    = module.unix.aws_sg_nbuclient_ids
  
  # Instance counts
  aws_number = {
    dc         = 2
    adfs       = 0
    dhcp       = 1
    exchange   = 0
    fs         = 1
    ipam       = 0
    mgmt       = 1
    nps        = 0
    rdsh       = 0
    sharepoint = 0
    sql        = 0
    simpana    = 0
    sofs       = 0
    wac        = 1
    wds        = 0
    wsus       = 1
    pki-rca    = 0
    pki-ica    = 0
    pki-crl    = 0
    pki-ndes   = 0
    da         = 0
  }
}
```

## Security Groups

### RDP Security Group

Provides administrative access to Windows servers.

**Ingress Rules:**

- RDP (3389/tcp) from admin CIDR blocks
- SSH (22/tcp) from admin CIDR blocks
- WinRM (5985-5986/tcp) from admin CIDR blocks

**Egress Rules:**

- All traffic (IPv4 and IPv6)

### Domain Member Security Group

Provides Active Directory domain member traffic.

**Ingress Rules:**

- ICMP ping
- DNS (53/tcp, 53/udp)
- Kerberos (88/tcp, 88/udp)
- NTP (123/udp)
- RPC endpoint mapper (135/tcp)
- LDAP (389/tcp, 389/udp)
- SMB/CIFS (445/tcp, 445/udp)
- LDAPS (636/tcp, 636/udp)
- Kerberos password change (749/udp)
- LDAP Global Catalog (3268-3269/tcp)
- WinRM (5985-5986/tcp)
- Dynamic RPC (49152-65535/tcp)
- FusionInventory agent (62354/tcp)

**Egress Rules:**

- All traffic (IPv4 and IPv6)

## Common Configuration Pattern

All Windows service modules use a common configuration pattern defined in `locals.tf`:

```hcl
locals {
  # Common Windows configuration shared across all modules
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
}
```

## AMI Selection

- **Windows Server 2022**: Default for most services
- **SQL Server 2019**: Used for SQL Server module
- **Windows Server 2019**: Available for compatibility
- **Windows Server 2016**: Available for legacy applications

## Notes

- All Windows instances enforce IMDSv2 for enhanced security
- Instances are deployed across multiple availability zones for high availability
- Security groups follow the principle of least privilege
- All resources are tagged for cost allocation and management
- User data scripts integrate with AWS Secrets Manager for credential management
- PowerShell scripts include comprehensive error handling and logging
- Ansible playbooks are used for post-deployment configuration
- Domain controllers should be deployed before other domain-dependent services
- The module uses locals to reduce code duplication and improve maintainability
