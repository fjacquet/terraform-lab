# Terraform-Lab Architecture

## Overview

This project uses a modern, flattened Terraform architecture that eliminates unnecessary abstraction layers and provides a single source of truth for all service configurations.

## Architecture Principles

1. **KISS (Keep It Simple, Stupid)**: Eliminate unnecessary complexity
2. **DRY (Don't Repeat Yourself)**: Single source of truth for configuration
3. **Modern Terraform**: Leverage for_each, optional(), and moved blocks
4. **Backward Compatible**: Maintain existing functionality and outputs

## Directory Structure

```
terraform-lab/
├── main.tf                      # Core orchestration (~70 lines)
├── security-groups.tf           # Security group definitions (~350 lines)
├── data-sources.tf              # AMI lookups and data sources (~100 lines)
├── locals.tf                    # Service configurations + helper maps
├── variables.tf                 # Input variables
├── outputs.tf                   # Output values (backward compatible)
├── versions.tf                  # Terraform and provider versions
├── backend.tf                   # Terraform backend and SSH key pair
│
├── modules/
│   └── service/                 # UNIFIED service module (Windows + Unix)
│       ├── main.tf              # Generic instance, SG, and DNS resources
│       ├── variables.tf         # Module inputs
│       ├── outputs.tf           # Module outputs
│       ├── versions.tf          # Module version constraints
│       └── README.md            # Module documentation
│
├── global/                      # Global infrastructure (VPC, IAM, Route53)
│   ├── vpc/
│   ├── iam/
│   ├── route53/
│   └── ...
│
├── user_data/                   # Bootstrap scripts
│   ├── config-win.ps1           # Windows initialization
│   └── config-linux.sh          # Linux initialization
│
├── playbooks/                   # Ansible configuration management
│   ├── system/
│   └── apps/
│
├── inventory/                   # Ansible dynamic inventory
│   └── aws_ec2.yaml
│
└── docs/                        # Documentation
    ├── CONFIGURATION.md         # Configuration guide
    ├── DEPLOYMENT-STATUS.md     # Deployment instructions
    ├── MIGRATION-GUIDE.md       # Migration instructions
    ├── SECURITY.md              # Security best practices
    └── TERRAFORM-DOCS.md        # Terraform documentation
```

### File Organization

**Core Terraform Files:**
- `main.tf` - High-level orchestration (global module + service deployment)
- `security-groups.tf` - All security group definitions (RDP, SSH, domain, simpana)
- `data-sources.tf` - AMI lookups for Windows, Linux, BSD
- `locals.tf` - Service configurations and computed values
- `variables.tf` - Input variables and validation
- `outputs.tf` - Output values for deployed services

**Benefits of Split Structure:**
- ✅ Easy to scan main.tf (70 lines vs 500 lines)
- ✅ Security groups isolated for review
- ✅ Data sources clearly separated
- ✅ Logical organization by concern
- ✅ Follows Terraform community conventions

## Old vs New Architecture

### Old Architecture (3 Levels)

```
root/main.tf
  ├── module.microsoft (pass-through layer)
  │   ├── module.adds
  │   ├── module.adfs
  │   ├── module.exchange
  │   └── ... (16 more modules)
  │
  └── module.unix (pass-through layer)
      ├── module.guacamole
      ├── module.vault
      └── ... (7 more modules)
```

**Problems:**
- 3 levels of indirection
- microsoft/ and unix/ are just pass-through wrappers
- Configuration scattered across 30+ files
- Duplicate code in every module
- Hard to understand and maintain

### New Architecture (2 Levels)

```
root/main.tf
  └── module.services (for_each over all services)
      ├── ["adds"]
      ├── ["adfs"]
      ├── ["exchange"]
      ├── ["guacamole"]
      ├── ["vault"]
      └── ... (all services)
```

**Benefits:**
- 2 levels: root → service
- Single unified module for ALL services
- All configuration in ONE file (locals.tf)
- 90% less code
- Easy to understand and maintain

## Service Configuration

All service configurations are defined in `locals.tf`:

```hcl
locals {
  windows_services = {
    adds = {
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
    # ... more services
  }

  unix_services = {
    guacamole = {
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
    # ... more services
  }

  all_services = merge(local.windows_services, local.unix_services)
}
```

## Service Deployment

Services are deployed using a single for_each loop:

```hcl
module "services" {
  for_each = { for k, v in local.all_services : k => v if var.aws_number[k] > 0 }

  source = "./modules/service"

  service_name   = each.key
  instance_count = var.aws_number[each.key]
  config         = each.value

  # Common configuration passed ONCE for ALL services
  ami_ids                  = local.ami_ids
  common_metadata_options  = local.common_instance_metadata_options
  common_root_block_device = local.common_instance_root_block_device
  vpc_id                   = module.global.aws_vpc_id
  subnets                  = { ... }
  cidr_blocks              = local.cidr_blocks
  # ... other common config
}
```

## Unified Service Module

The `modules/service/` module is generic and handles:

1. **EC2 Instances**: Creates instances based on configuration
2. **Security Groups**: Optionally creates service-specific security groups
3. **Route53 Records**: Creates private and public DNS records
4. **EBS Volumes**: Optionally creates additional volumes (e.g., for NBU)

The module uses the `os_type` field to handle Windows vs Unix differences:

- **Windows**: Uses RDP, domain-member, and simpana-client security groups
- **Unix**: Uses SSH security group
- **BSD**: No default security groups

## Configuration Options

Each service configuration supports:

| Field | Type | Description |
|-------|------|-------------|
| `instance_type` | string | EC2 instance type (e.g., "t3.medium") |
| `subnet_type` | string | Subnet type: back, web, mgmt, exchange, backup |
| `os_type` | string | Operating system: windows, debian, rhel, bsd |
| `ami_type` | string | AMI type: windows2022, sql2019, debian, rhel9, bsd |
| `user_data` | string | Path to user data script |
| `root_volume_size` | number | Root volume size in GB |
| `has_public_dns` | bool | Create public DNS records |
| `creates_sg` | bool | Create service-specific security group |
| `needs_domain_sg` | bool | Requires domain-member security group |
| `needs_dc_sg` | bool | Requires DC security group |
| `needs_nbu_sg` | bool | Requires NBU client security group |
| `skip_cidr` | bool | Don't pass CIDR blocks to module |
| `skip_own_sg` | bool | Don't include own SG in list |
| `cidr_override` | string | Use different CIDR blocks (e.g., "web", "sql") |
| `extra_dns_names` | list(string) | Additional DNS names (e.g., ["bastion"]) |
| `extra_volumes` | map(number) | Additional EBS volumes |
| `ingress_rules` | list(object) | Security group ingress rules |

## Adding a New Service

To add a new service, you only need to edit **2 files**:

### 1. Add Configuration to `locals.tf`

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
      needs_domain_sg  = true  # Optional: if service needs domain membership
      
      # Optional: Custom security group rules
      ingress_rules = [
        {
          description = "Custom port"
          from_port   = 8080
          to_port     = 8080
          protocol    = "tcp"
          cidr_blocks = ["10.0.0.0/16"]
        }
      ]
    }
  }
}
```

### 2. Add to `variables.tf`

```hcl
variable "aws_number" {
  description = "Number of instances to create for each service type (0-10)"
  type        = map(number)
  
  default = {
    # ... existing services
    "mynewservice" = 0  # Set to 0 by default, enable when needed
  }
}
```

### 3. Deploy

```bash
# Validate configuration
terraform validate

# Review changes
terraform plan

# Deploy
terraform apply
```

That's it! The unified service module automatically handles:
- EC2 instance creation
- Security group creation (if `creates_sg = true`)
- DNS record creation (private and optionally public)
- Proper security group associations based on `os_type`
- User data script application
- Volume encryption
- IMDSv2 enforcement

### Configuration Options Reference

See [modules/service/README.md](modules/service/README.md) for complete configuration options including:
- `extra_volumes`: Additional EBS volumes
- `extra_dns_names`: Additional DNS aliases
- `cidr_override`: Use different CIDR blocks
- `skip_cidr`: Don't pass CIDR blocks
- `needs_dc_sg`: Require DC security group
- `needs_nbu_sg`: Require NBU client security group
- And more...

## Modifying a Service

To modify a service configuration:

1. **Edit `locals.tf`**: Change the service configuration
2. **Run `terraform plan`**: Review changes
3. **Run `terraform apply`**: Apply changes

All changes are in ONE file!

## Security Groups

Security groups are defined at two levels:

1. **Common Security Groups** (in `main.tf`):
   - `rdp`: Windows administrative access
   - `ssh`: Unix/Linux administrative access
   - `domain_member`: Active Directory domain traffic

2. **Service-Specific Security Groups** (created by unified module):
   - Defined in service configuration via `ingress_rules`
   - Created only if `creates_sg = true`

## DNS Records

DNS records are automatically created:

- **Private DNS**: Always created (e.g., `adds-0.ez-lab.xyz`)
- **Public DNS**: Created if `has_public_dns = true`
- **Extra DNS**: Created if `extra_dns_names` is specified

## State Migration

The migration from old to new architecture uses Terraform's `moved` blocks to safely relocate resources in state without recreation.

See [MIGRATION-GUIDE.md](MIGRATION-GUIDE.md) for detailed migration instructions.

## Code Metrics

### Before Refactoring
- **Lines of Code**: ~2,000 (duplicate code across modules)
- **Files**: 30+ module files
- **Levels**: 3 (root → microsoft/unix → service)
- **Maintenance**: Edit 18-30 files for common changes

### After Refactoring
- **Lines of Code**: ~300 (90% reduction)
- **Files**: 1 main file + 1 unified module
- **Levels**: 2 (root → service)
- **Maintenance**: Edit 1-3 files for common changes

## Best Practices

1. **Always use `terraform plan`** before applying changes
2. **Test in non-production** before applying to production
3. **Backup state** before major changes
4. **Use moved blocks** when refactoring to avoid resource recreation
5. **Document changes** in commit messages
6. **Keep service configurations** in `locals.tf` organized and commented

## Troubleshooting

### Service not deploying
- Check `var.aws_number[service_name] > 0`
- Verify service configuration in `locals.tf`
- Check AMI availability in your region

### Security group issues
- Verify `creates_sg` is set correctly
- Check `ingress_rules` configuration
- Ensure referenced security groups exist

### DNS issues
- Verify `dns_zone_id` and `dns_public_zone_id` are correct
- Check `has_public_dns` setting
- Ensure Route53 zones exist

## Future Enhancements

Potential improvements for the future:

1. **Dynamic Security Group Rules**: Generate rules from service configuration
2. **Multi-Region Support**: Deploy to multiple regions simultaneously
3. **Auto-Scaling**: Add auto-scaling group support
4. **Load Balancers**: Integrate ALB/NLB for services
5. **Monitoring**: Add CloudWatch alarms and dashboards
6. **Backup**: Integrate AWS Backup for automated backups

## References

- [Terraform for_each Documentation](https://www.terraform.io/language/meta-arguments/for_each)
- [Terraform Moved Blocks](https://www.terraform.io/language/modules/develop/refactoring)
- [Terraform optional() Function](https://www.terraform.io/language/expressions/type-constraints#optional)
- [AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Project Requirements](.kiro/specs/infrastructure-improvements/requirements.md)
- [Project Design](.kiro/specs/infrastructure-improvements/design.md)
