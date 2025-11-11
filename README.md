# terraform-lab

Automated AWS lab environment for testing Windows and Linux services. Deploy complete infrastructure with Active Directory, Exchange, SQL Server, and more using modern Terraform patterns.

[![Quality Gate](https://sonarcloud.io/api/project_badges/measure?project=fjacquet_terraform-lab&metric=alert_status)](https://sonarcloud.io/dashboard?id=fjacquet_terraform-lab)
[![Build](https://github.com/fjacquet/terraform-lab/actions/workflows/build.yml/badge.svg)](https://github.com/fjacquet/terraform-lab/actions/workflows/build.yml)
[![Vulnerabilities](https://snyk.io/test/github/fjacquet/terraform-lab/badge.svg)](https://snyk.io/test/github/fjacquet/terraform-lab)

## Quick Start

```bash
# 1. Install dependencies
pip3 install -r requirements.txt
ansible-galaxy install -r requirements.yml

# 2. Configure services (edit terraform.tfvars)
aws_number = {
  "guacamole" = 1  # Bastion host
  "adds"      = 2  # Domain controllers
}

# 3. Deploy
terraform init
terraform plan
terraform apply

# 4. Configure with Ansible
ansible-parallel playbooks/system/*.yml
ansible-parallel playbooks/apps/*.yml
```

## What You Get

**23 Services** across Windows and Linux:

| Windows (16) | Linux (7) |
|-------------|-----------|
| Active Directory, Exchange, SharePoint | Guacamole (Bastion), Vault |
| SQL Server, DHCP, DNS, IPAM | GLPI, NetBackup, Oracle |
| File Server, RDS, WSUS, WAC | Redis, FreeBSD |

**Modern Architecture:**
- Single unified module for all services
- All configs in one file (`locals.tf`)
- 90% less code than traditional approach
- Add services by editing 2 files

## Requirements

- Terraform >= 1.0
- AWS Provider ~> 5.0
- Python 3.x + Ansible
- AWS Account with appropriate permissions

## Key Features

✅ **Secure by Default**
- IMDSv2 enforced on all instances
- Restricted admin access via CIDR blocks
- AWS Secrets Manager integration
- VPC endpoints for private connectivity

✅ **Easy to Use**
- Deploy services by setting instance count
- Single source of truth for configuration
- Backward compatible outputs
- Comprehensive documentation

✅ **Production Ready**
- Automated tagging for cost tracking
- Pre-commit hooks for code quality
- Ansible automation included
- Battle-tested architecture

## Documentation

| Document | Description |
|----------|-------------|
| [ARCHITECTURE.md](ARCHITECTURE.md) | Architecture overview and design patterns |
| [docs/DEPLOYMENT-STATUS.md](docs/DEPLOYMENT-STATUS.md) | Deployment guide and instructions |
| [docs/SECURITY.md](docs/SECURITY.md) | Security configuration and best practices |
| [docs/CONFIGURATION.md](docs/CONFIGURATION.md) | Detailed configuration options |
| [modules/service/README.md](modules/service/README.md) | Service module documentation |

## Common Tasks

### Deploy a Service

```hcl
# In terraform.tfvars
aws_number = {
  "myservice" = 2  # Deploy 2 instances
}
```

```bash
terraform apply
```

### Add a New Service

1. Add config to `locals.tf`
2. Add to `aws_number` in `variables.tf`
3. Deploy with `terraform apply`

See [ARCHITECTURE.md](ARCHITECTURE.md#adding-a-new-service) for details.

### Access Services

```bash
# Via Guacamole bastion (recommended)
https://guacamole-0.ez-lab.xyz:8080

# View deployed services
terraform output deployed_services
```

## Project Structure

```
terraform-lab/
├── main.tf              # Service deployment
├── locals.tf            # Service configurations
├── modules/service/     # Unified service module
├── global/              # VPC, IAM, Route53
├── playbooks/           # Ansible automation
└── docs/                # Documentation
```

## Support

- 📖 [Full Documentation](docs/)
- 🐛 [Report Issues](https://github.com/fjacquet/terraform-lab/issues)
- 💬 [Discussions](https://github.com/fjacquet/terraform-lab/discussions)

## License

This project is for lab and educational purposes.

---

**Need help?** Start with [docs/DEPLOYMENT-STATUS.md](docs/DEPLOYMENT-STATUS.md) for deployment instructions.
