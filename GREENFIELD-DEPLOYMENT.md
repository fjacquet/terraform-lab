# Greenfield Deployment Guide

Since this is a **greenfield deployment** (no existing infrastructure), we can deploy directly with the new flattened architecture without needing migration steps.

## Quick Start

### Step 1: Activate New Architecture

```bash
# Rename new files to active
mv main-new.tf main.tf
mv outputs-new.tf outputs.tf

# Remove old files (not needed for greenfield)
rm main-old.tf 2>/dev/null || true
rm outputs-old.tf 2>/dev/null || true

# Remove moved blocks (not needed for greenfield)
rm moved-blocks.tf
```

### Step 2: Initialize Terraform

```bash
# Initialize Terraform
terraform init

# Validate configuration
terraform validate
```

### Step 3: Configure Services

Edit `variables.tf` or create a `terraform.tfvars` file to specify which services to deploy:

```hcl
# terraform.tfvars
aws_region = "eu-west-1"

azs = [
  "eu-west-1a",
  # "eu-west-1b",
  # "eu-west-1c",
]

# Enable services by setting count > 0
aws_number = {
  "guacamole"  = 1  # Bastion host (recommended first)
  "adds"       = 0  # Active Directory
  "exchange"   = 0  # Exchange Server
  "sql"        = 0  # SQL Server
  # ... set others as needed
}

# Security: Restrict admin access (recommended)
enable_public_admin_access = false
admin_cidr_blocks = ["10.0.0.0/16"]  # VPC only

# Or allow public access for testing (not recommended for production)
# enable_public_admin_access = true
```

### Step 4: Plan Deployment

```bash
# Generate execution plan
terraform plan

# Review the plan carefully
# You should see resources being created (no "moved" operations needed)
```

### Step 5: Deploy Infrastructure

```bash
# Apply the configuration
terraform apply

# Type 'yes' when prompted
```

### Step 6: Verify Deployment

```bash
# Check deployed services
terraform output deployed_services

# Check security groups
terraform output service_security_groups

# Verify no changes needed
terraform plan
# Expected: "No changes. Your infrastructure matches the configuration."
```

## Recommended Deployment Order

For a new lab environment, deploy services in this order:

### Phase 1: Foundation (Deploy First)
```hcl
aws_number = {
  "guacamole" = 1  # Bastion host for access
}
```

Deploy and verify access to Guacamole before proceeding.

### Phase 2: Core Services
```hcl
aws_number = {
  "guacamole" = 1
  "adds"      = 2  # Domain controllers (2 for redundancy)
  "dhcp"      = 1  # DHCP server
}
```

### Phase 3: Infrastructure Services
```hcl
aws_number = {
  "guacamole" = 1
  "adds"      = 2
  "dhcp"      = 1
  "ipam"      = 1  # IP Address Management
  "wac"       = 1  # Windows Admin Center
  "mgmt"      = 1  # Management server
}
```

### Phase 4: Application Services
```hcl
aws_number = {
  # ... previous services
  "exchange"   = 1  # Exchange Server
  "sharepoint" = 1  # SharePoint
  "sql"        = 1  # SQL Server
  "fs"         = 1  # File Server
}
```

### Phase 5: Optional Services
```hcl
aws_number = {
  # ... previous services
  "vault"   = 1  # HashiCorp Vault
  "glpi"    = 1  # IT Asset Management
  "redis"   = 1  # Redis Cache
  "nbu"     = 1  # NetBackup
  "oracle"  = 1  # Oracle Database
}
```

## Architecture Overview

Your new deployment uses the **flattened 2-level architecture**:

```
root/main.tf → modules/service/ (ONE module for ALL services)
root/locals.tf (ALL service configs in ONE place)
```

### Key Files

- **`main.tf`**: Root module with unified service deployment
- **`locals.tf`**: All service configurations (single source of truth)
- **`variables.tf`**: Input variables
- **`outputs.tf`**: Output values
- **`modules/service/`**: Unified service module

## Adding New Services

To add a new service:

1. **Set instance count** in `terraform.tfvars`:
```hcl
aws_number = {
  "mynewservice" = 1
}
```

2. **Ensure service is defined** in `locals.tf` (already done for all services)

3. **Deploy**:
```bash
terraform plan
terraform apply
```

That's it! No need to create new modules or update multiple files.

## Modifying Services

To modify a service configuration:

1. **Edit `locals.tf`**: Change the service configuration
2. **Run `terraform plan`**: Review changes
3. **Run `terraform apply`**: Apply changes

Example - Change instance type:
```hcl
# In locals.tf
windows_services = {
  adds = {
    instance_type = "t3.large"  # Changed from t3.medium
    # ... rest of config
  }
}
```

## Security Configuration

### Recommended for Production

```hcl
# Restrict administrative access to VPC only
enable_public_admin_access = false
admin_cidr_blocks = ["10.0.0.0/16"]
```

### For Testing/Development

```hcl
# Allow public access (use with caution)
enable_public_admin_access = true
```

### Custom CIDR Blocks

```hcl
# Allow access from specific IP ranges
enable_public_admin_access = false
admin_cidr_blocks = [
  "10.0.0.0/16",      # VPC
  "203.0.113.0/24",   # Office network
  "198.51.100.0/24",  # VPN network
]
```

## Accessing Services

### Via Guacamole (Recommended)

1. Deploy Guacamole first
2. Get public DNS: `terraform output deployed_services`
3. Access: `https://guacamole-0.ez-lab.xyz:8080`
4. Use Guacamole to access other services

### Direct Access (if enabled)

If `enable_public_admin_access = true`:
- RDP to Windows: `mstsc /v:service-0.ez-lab.xyz`
- SSH to Linux: `ssh admin@service-0.ez-lab.xyz`

## Ansible Configuration

After Terraform deployment, configure services with Ansible:

```bash
# Configure base systems
ansible-parallel playbooks/system/*.yml

# Configure applications
ansible-parallel playbooks/apps/*.yml
```

## Troubleshooting

### Issue: "Module not found"

**Solution**: Ensure `modules/service/` directory exists with all files:
```bash
ls -la modules/service/
# Should show: main.tf, variables.tf, outputs.tf, versions.tf, README.md
```

### Issue: "Invalid AMI ID"

**Solution**: AMI IDs are region-specific. The configuration uses data sources to find the latest AMIs automatically. Ensure your region is supported.

### Issue: "Insufficient capacity"

**Solution**: Try a different availability zone or instance type:
```hcl
azs = ["eu-west-1b"]  # Try different AZ
# or
instance_type = "t3.small"  # Try smaller instance
```

### Issue: "Service not deploying"

**Solution**: Check instance count:
```bash
terraform console
> var.aws_number["service-name"]
# Should be > 0
```

## Cleanup

To destroy all infrastructure:

```bash
# Destroy everything
terraform destroy

# Or destroy specific services
terraform destroy -target=module.services["guacamole"]
```

## Cost Optimization

### Minimal Lab (Low Cost)
```hcl
aws_number = {
  "guacamole" = 1  # ~$25/month
}
```

### Basic Lab (Medium Cost)
```hcl
aws_number = {
  "guacamole" = 1  # Bastion
  "adds"      = 1  # Domain Controller
  "mgmt"      = 1  # Management
}
# ~$75/month
```

### Full Lab (Higher Cost)
```hcl
# All services enabled
# ~$500-1000/month depending on instance types
```

### Cost Saving Tips

1. **Use t3.micro/small** for testing
2. **Stop instances** when not in use
3. **Use Spot Instances** for non-critical services
4. **Delete unused EBS volumes**
5. **Use VPC endpoints** to reduce data transfer costs

## Next Steps

1. ✅ Deploy Guacamole (bastion host)
2. ✅ Verify access to Guacamole
3. ✅ Deploy core services (ADDS, DHCP)
4. ✅ Configure services with Ansible
5. ✅ Deploy application services as needed
6. ✅ Set up monitoring and backups
7. ✅ Document your specific configuration

## Support

For questions or issues:

1. Check [ARCHITECTURE.md](ARCHITECTURE.md) for architecture details
2. Check [modules/service/README.md](modules/service/README.md) for module documentation
3. Review Terraform plan output carefully
4. Check AWS Console for resource status

## Benefits of New Architecture

- **90% less code**: Easier to maintain
- **Single source of truth**: All config in `locals.tf`
- **Consistent behavior**: Same module for all services
- **Easy to extend**: Add services in minutes
- **Modern Terraform**: Uses latest features

## Congratulations! 🎉

You're deploying with the new flattened architecture from day one. This gives you:

- Simpler configuration
- Easier maintenance
- Better documentation
- Modern Terraform patterns
- Faster development

Enjoy your new infrastructure! 🚀
