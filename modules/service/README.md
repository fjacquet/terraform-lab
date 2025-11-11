# Unified Service Module

This module provides a unified interface for deploying both Windows and Unix services in AWS. It replaces 25+ individual service modules with a single, flexible module that handles all service types.

## Features

- **Universal**: Works for Windows, Linux, and BSD services
- **Flexible**: Configurable via service configuration object
- **Consistent**: Same behavior across all services
- **Efficient**: Reduces code duplication by 90%
- **Modern**: Uses Terraform 1.3+ features like optional()

## Usage

### Basic Example

```hcl
module "service" {
  source = "./modules/service"

  service_name   = "guacamole"
  instance_count = 1
  
  config = {
    instance_type    = "t3.medium"
    subnet_type      = "mgmt"
    os_type          = "debian"
    ami_type         = "debian"
    user_data        = "user_data/config-linux.sh"
    root_volume_size = 80
    has_public_dns   = true
    creates_sg       = true
  }

  # Common configuration
  ami_ids                  = local.ami_ids
  common_metadata_options  = local.common_instance_metadata_options
  common_root_block_device = local.common_instance_root_block_device
  vpc_id                   = module.global.aws_vpc_id
  subnets                  = { ... }
  cidr_blocks              = local.cidr_blocks
  azs                      = var.azs
  iam_instance_profile     = module.global.aws_iip_assumerole
  key_pair_id              = aws_key_pair.auth.id
  dns_zone_id              = module.global.dns_zone_id
  dns_public_zone_id       = var.public_dns_id
  dns_suffix               = var.dns_suffix
  security_groups          = { ... }
}
```

### Advanced Example with Security Group Rules

```hcl
module "service" {
  source = "./modules/service"

  service_name   = "adds"
  instance_count = 2
  
  config = {
    instance_type    = "t3.medium"
    subnet_type      = "back"
    os_type          = "windows"
    ami_type         = "windows2022"
    user_data        = "user_data/config-win.ps1"
    root_volume_size = 30
    has_public_dns   = false
    creates_sg       = true
    needs_domain_sg  = true
    
    # Custom security group rules
    ingress_rules = [
      {
        description = "DNS TCP"
        from_port   = 53
        to_port     = 53
        protocol    = "tcp"
        self        = true
      },
      {
        description = "DNS UDP"
        from_port   = 53
        to_port     = 53
        protocol    = "udp"
        self        = true
      },
      {
        description = "Kerberos TCP"
        from_port   = 88
        to_port     = 88
        protocol    = "tcp"
        self        = true
      }
    ]
  }

  # ... common configuration
}
```

### Example with Additional Volumes

```hcl
module "service" {
  source = "./modules/service"

  service_name   = "nbu"
  instance_count = 1
  
  config = {
    instance_type    = "t3.medium"
    subnet_type      = "backup"
    os_type          = "rhel"
    ami_type         = "rhel9"
    user_data        = "user_data/config-linux.sh"
    root_volume_size = 30
    has_public_dns   = false
    creates_sg       = false
    
    # Additional EBS volumes
    extra_volumes = {
      nbu_backups = 500  # 500 GB for backups
      nbu_openv   = 50   # 50 GB for catalog
    }
  }

  # ... common configuration
}
```

## Configuration Object

The `config` object supports the following fields:

### Required Fields

| Field | Type | Description |
|-------|------|-------------|
| `instance_type` | string | EC2 instance type (e.g., "t3.medium") |
| `subnet_type` | string | Subnet type: back, web, mgmt, exchange, backup |
| `os_type` | string | Operating system: windows, debian, rhel, bsd |
| `ami_type` | string | AMI type: windows2022, sql2019, debian, rhel9, bsd |
| `user_data` | string | Path to user data script |
| `root_volume_size` | number | Root volume size in GB |
| `has_public_dns` | bool | Create public DNS records |

### Optional Fields

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `creates_sg` | bool | false | Create service-specific security group |
| `needs_domain_sg` | bool | false | Requires domain-member security group |
| `needs_dc_sg` | bool | false | Requires DC security group |
| `needs_nbu_sg` | bool | false | Requires NBU client security group |
| `skip_cidr` | bool | false | Don't pass CIDR blocks to module |
| `skip_own_sg` | bool | false | Don't include own SG in list |
| `cidr_override` | string | null | Use different CIDR blocks (e.g., "web", "sql") |
| `extra_dns_names` | list(string) | [] | Additional DNS names (e.g., ["bastion"]) |
| `extra_volumes` | map(number) | {} | Additional EBS volumes (name → size in GB) |
| `ingress_rules` | list(object) | [] | Security group ingress rules |

### Ingress Rule Object

```hcl
{
  description      = string           # Rule description
  from_port        = number           # Start port
  to_port          = number           # End port
  protocol         = string           # Protocol: tcp, udp, icmp, -1 (all)
  cidr_blocks      = list(string)     # Optional: CIDR blocks
  ipv6_cidr_blocks = list(string)     # Optional: IPv6 CIDR blocks
  self             = bool             # Optional: Allow from same SG
  security_groups  = list(string)     # Optional: Source security groups
}
```

## Inputs

| Name | Description | Type | Required |
|------|-------------|------|----------|
| service_name | Name of the service | string | yes |
| instance_count | Number of instances | number | yes |
| config | Service configuration | object | yes |
| ami_ids | Map of AMI types to IDs | map(string) | yes |
| common_metadata_options | IMDSv2 configuration | object | yes |
| common_root_block_device | Root device configuration | object | yes |
| vpc_id | VPC ID | string | yes |
| subnets | Map of subnet types to IDs | object | yes |
| cidr_blocks | Map of subnet types to CIDRs | object | yes |
| azs | Availability zones | list(string) | yes |
| iam_instance_profile | IAM instance profile | string | yes |
| key_pair_id | SSH key pair ID | string | yes |
| dns_zone_id | Private Route53 zone ID | string | yes |
| dns_public_zone_id | Public Route53 zone ID | string | yes |
| dns_suffix | DNS suffix | string | yes |
| security_groups | Common security group IDs | object | yes |
| nbu_client_sg_ids | NBU client SG IDs | list(string) | no |

## Outputs

| Name | Description |
|------|-------------|
| instance_ids | List of EC2 instance IDs |
| private_ips | List of private IP addresses |
| public_ips | List of public IP addresses |
| security_group_id | Service security group ID (if created) |
| dns_names | List of private DNS names |
| public_dns_names | List of public DNS names (if applicable) |

## How It Works

### 1. Instance Creation

The module creates EC2 instances based on the configuration:

- Uses the specified AMI type from `ami_ids` map
- Places instances in subnets based on `subnet_type`
- Distributes across availability zones
- Applies IMDSv2 enforcement
- Encrypts root volumes
- Applies user data script

### 2. Security Groups

The module handles security groups intelligently:

- **Windows services**: Automatically includes RDP, domain-member, and simpana-client SGs
- **Unix services**: Automatically includes SSH SG
- **BSD services**: No default SGs
- **Service-specific SG**: Created if `creates_sg = true`
- **Custom rules**: Applied via `ingress_rules` configuration

### 3. DNS Records

The module creates DNS records automatically:

- **Private DNS**: Always created (e.g., `service-0.ez-lab.xyz`)
- **Public DNS**: Created if `has_public_dns = true`
- **Extra DNS**: Created for names in `extra_dns_names` list

### 4. Additional Volumes

For services that need extra storage (like NetBackup):

- Creates EBS volumes based on `extra_volumes` map
- Attaches volumes to first instance
- Uses device names /dev/sdf, /dev/sdg, etc.
- Encrypts volumes

## OS Type Handling

The module uses `os_type` to determine behavior:

### Windows (`os_type = "windows"`)
- Includes RDP security group
- Includes domain-member security group
- Includes simpana-client security group
- Uses Windows user data script
- Tags with `system = "windows"`

### Debian/Ubuntu (`os_type = "debian"`)
- Includes SSH security group
- Uses Linux user data script
- Tags with `system = "debian"`

### RHEL/CentOS (`os_type = "rhel"`)
- Includes SSH security group
- Uses Linux user data script
- Tags with `system = "rhel"`

### FreeBSD (`os_type = "bsd"`)
- No default security groups
- Uses Linux user data script
- Tags with `system = "bsd"`

## Subnet Types

The module supports these subnet types:

- `back`: Backend/private subnets
- `web`: Web/DMZ subnets
- `mgmt`: Management subnets
- `exchange`: Exchange-specific subnets
- `backup`: Backup subnets

## CIDR Override

Some services need different CIDR blocks than their subnet type:

```hcl
config = {
  subnet_type   = "back"      # Deployed to back subnet
  cidr_override = "sql"       # But uses SQL CIDR blocks
  # ...
}
```

## Examples by Service Type

### Domain Controller (Windows)

```hcl
config = {
  instance_type    = "t3.medium"
  subnet_type      = "back"
  os_type          = "windows"
  ami_type         = "windows2022"
  user_data        = "user_data/config-win.ps1"
  root_volume_size = 30
  has_public_dns   = false
  creates_sg       = true
  needs_domain_sg  = true
}
```

### Web Server (Linux)

```hcl
config = {
  instance_type    = "t3.medium"
  subnet_type      = "web"
  os_type          = "debian"
  ami_type         = "debian"
  user_data        = "user_data/config-linux.sh"
  root_volume_size = 30
  has_public_dns   = true
  creates_sg       = true
}
```

### Database Server (SQL Server)

```hcl
config = {
  instance_type    = "t3.large"
  subnet_type      = "back"
  os_type          = "windows"
  ami_type         = "sql2019"
  user_data        = "user_data/config-win.ps1"
  root_volume_size = 100
  has_public_dns   = false
  creates_sg       = true
  cidr_override    = "sql"
}
```

### Bastion Host (Guacamole)

```hcl
config = {
  instance_type    = "t3.medium"
  subnet_type      = "mgmt"
  os_type          = "debian"
  ami_type         = "debian"
  user_data        = "user_data/config-linux.sh"
  root_volume_size = 80
  has_public_dns   = true
  creates_sg       = true
  extra_dns_names  = ["bastion"]
}
```

## Requirements

- Terraform >= 1.0
- AWS Provider ~> 5.0

## Limitations

- Maximum 10 instances per service (configurable via validation)
- Extra volumes only attached to first instance
- Security group rules must be defined in configuration
- PKI services require special handling (not yet implemented)

## Future Enhancements

- Dynamic security group rule generation
- Auto-scaling group support
- Load balancer integration
- CloudWatch alarms
- Backup integration
- Multi-region support

## Contributing

When modifying this module:

1. Maintain backward compatibility
2. Update this README
3. Test with multiple service types
4. Verify security group behavior
5. Check DNS record creation
6. Test in non-production first

## License

This module is part of the terraform-lab project.

## References

- [Root Architecture](../../ARCHITECTURE.md)
- [Migration Guide](../../MIGRATION-GUIDE.md)
- [Terraform for_each Documentation](https://www.terraform.io/language/meta-arguments/for_each)
- [Terraform optional() Function](https://www.terraform.io/language/expressions/type-constraints#optional)
