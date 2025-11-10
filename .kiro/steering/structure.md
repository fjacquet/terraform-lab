## Project Structure

### Root Level

- `main.tf`: Root module orchestrating global, unix, and microsoft modules
- `variables.tf`: Global variables (aws_number map controls VM counts per service)
- `backend.tf`: Terraform backend and AWS provider configuration
- `ansible.cfg`: Ansible configuration with dynamic AWS EC2 inventory

### Terraform Modules

#### `/global/`

Core AWS infrastructure shared across all services:

- `vpc/`: VPC, subnets (web, back, backup, exchange, mgmt, sql), routing
- `iam/`: IAM roles and instance profiles
- `route53/`: DNS zones (private and public)
- `dynamodb/`: DynamoDB tables for state locking
- `demand/`: On-demand capacity reservations

#### `/microsoft/`

Windows-based services, each in its own subdirectory:

- `adds/`: Active Directory Domain Services
- `adcs/`: PKI (Root CA, Issuing CA, CRL, NDES)
- `adfs/`: Active Directory Federation Services
- `exchange/`: Exchange Server
- `sharepoint/`: SharePoint Server
- `sql/`: SQL Server
- `dhcp/`, `ipam/`, `nps/`, `wds/`, `wsus/`: Network services
- `fs/`, `sofs/`: File services
- `rdsh/`: Remote Desktop Session Host
- `wac/`: Windows Admin Center
- `simpana/`: Commvault backup
- `mgmt/`: Management servers

Each module contains: `main.tf`, `variables.tf`, `outputs.tf`, `versions.tf`

#### `/unix/`

Linux/Unix services:

- `guacamole/`: Bastion host with web-based remote access
- `glpi/`: IT asset management
- `vault/`: HashiCorp Vault
- `nbu/`: Veritas NetBackup
- `oracle/`: Oracle Database
- `redis/`: Redis cache
- `bsd/`: FreeBSD systems

### Ansible Structure

#### `/playbooks/`

- `system/`: Base OS configuration (configure-windows.yml, configure-linux.yml)
- `apps/`: Application-specific configuration (configure_*.yml per service)
- `lab/`: Lab-specific configurations

#### `/roles/`

Ansible roles organized by OS and service:

- `win_*/`: Windows roles (win_server, win_domain_pdc, win_pki_*, etc.)
- `debian_*/`: Debian-specific roles
- `rhel_*/`: RHEL-specific roles
- `linux_*/`: Generic Linux roles (apache, mysql, php, redis, vault)
- `ms_*/`: Microsoft application roles (exchange, sharepoint)

#### `/inventory/`

- `aws_ec2.yaml`: Dynamic AWS EC2 inventory plugin configuration
- `group_vars/`: Variables by inventory group (tag-based grouping)

### Supporting Directories

- `/policy_json/`: IAM and VPC policy documents
- `/user_data/`: Cloud-init/user data scripts for initial VM setup
- `/post_setup/`: PowerShell scripts for post-deployment configuration
- `/OLD/`: Legacy scripts (deprecated, kept for reference)
- `/collections/`: Ansible collections directory

## Conventions

### Naming

- Terraform resources: `aws_<resource_type>_<name>` or `tf_ezlab_<name>`
- Security groups: Prefixed with `tf_ezlab_`
- DNS suffix: `ez-lab.xyz` (configurable)
- Modules use consistent variable names: `aws_number`, `aws_subnet_id`, `aws_vpc_id`, `dns_zone_id`

### Module Pattern

All service modules follow this structure:

1. Accept standard inputs (AMI, subnet, VPC, security groups, DNS zone)
2. Create EC2 instances with count controlled by `aws_number` variable
3. Create service-specific security groups
4. Output security group IDs and instance details
5. Use `flatten()` to combine security group lists

### Security Groups

- Base groups: `rdp`, `ssh`, `domain-member`
- Service-specific groups created per module
- Security groups reference each other (e.g., domain members reference DC group)

### Tagging

- AWS resources tagged for Ansible dynamic inventory
- Tags: `system` (windows/debian/rhel), `type` (service name)
- Ansible groups formed from tags: `tag_system_*`, `tag_type_*`
