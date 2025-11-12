# AMI Availability by Region

## Overview

Not all AMIs are available in all AWS regions. This document tracks AMI availability and provides guidance for handling missing AMIs.

---

## AMI Types and Availability

### ✅ Always Available (All Regions)

These AMIs are available in all AWS commercial regions:

| AMI Type | Description | Owner | Filter Pattern |
|----------|-------------|-------|----------------|
| **windows2022** | Windows Server 2022 | 801119661308 | `Windows_Server-2022-English-Full-Base-*` |
| **sql2019** | SQL Server 2019 on Windows 2019 | 801119661308 | `Windows_Server-2019-English-Full-SQL_2019_Standard-*` |
| **debian** | Debian 12 (Bookworm) | 136693071363 | `debian-12-amd64-*` |

### ⚠️ Limited Availability

These AMIs may not be available in all regions:

| AMI Type | Description | Owner | Filter Pattern | Notes |
|----------|-------------|-------|----------------|-------|
| **rhel9** | Red Hat Enterprise Linux 9 | 309956199498 | `RHEL-9.*_HVM-*-x86_64-*` | Generally available in major regions |
| **bsd** | FreeBSD 13 | 118940168514 | `FreeBSD 13.*-RELEASE-amd64*` | **Limited availability** - not in all regions |

---

## Regional Availability

### Confirmed Working Regions

| Region | windows2022 | sql2019 | debian | rhel9 | bsd |
|--------|-------------|---------|--------|-------|-----|
| us-east-1 | ✅ | ✅ | ✅ | ✅ | ✅ |
| us-west-2 | ✅ | ✅ | ✅ | ✅ | ✅ |
| eu-west-1 | ✅ | ✅ | ✅ | ✅ | ❌ |

### Known Issues

- **FreeBSD (bsd)**: Not available in eu-west-1 and many other regions
- **RHEL9**: May require Red Hat subscription in some regions

---

## Handling Missing AMIs

### Error Message

If you see this error:
```
Error: Your query returned no results. Please change your search criteria and try again.
  with data.aws_ami.bsd[0],
  on main.tf line 397, in data "aws_ami" "bsd":
```

### Solution

Set the instance count to 0 in your tfvars file:

```hcl
# In test.tfvars or your environment tfvars
aws_number = {
  # ... other services ...
  "bsd" = 0  # Disable if AMI not available in your region
}
```

---

## AMI Lookup Logic

### Conditional Lookups

The configuration uses conditional lookups to avoid querying for AMIs that aren't needed:

```hcl
# Only query RHEL9 AMI if nbu or oracle instances are requested
data "aws_ami" "rhel9" {
  count = (lookup(var.aws_number, "nbu", 0) + lookup(var.aws_number, "oracle", 0)) > 0 ? 1 : 0
  # ...
}

# Only query BSD AMI if bsd instances are requested
data "aws_ami" "bsd" {
  count = lookup(var.aws_number, "bsd", 0) > 0 ? 1 : 0
  # ...
}
```

### Safe Defaults

The AMI ID map uses safe defaults:

```hcl
locals {
  ami_ids = {
    windows2022 = data.aws_ami.windows2022.id  # Always available
    sql2019     = data.aws_ami.sql2019.id      # Always available
    debian      = data.aws_ami.debian.id       # Always available
    rhel9       = ... > 0 ? data.aws_ami.rhel9[0].id : ""  # Conditional
    bsd         = ... > 0 ? data.aws_ami.bsd[0].id : ""    # Conditional
  }
}
```

---

## Recommended Configuration by Region

### US Regions (us-east-1, us-west-2)
```hcl
# All AMIs available - use any services
aws_number = {
  "bsd" = 1  # ✅ Available
  # ... other services
}
```

### EU Regions (eu-west-1, eu-central-1)
```hcl
# FreeBSD not available - disable BSD
aws_number = {
  "bsd" = 0  # ❌ Not available
  # ... other services
}
```

### Asia Pacific Regions
```hcl
# Check availability before enabling
aws_number = {
  "bsd" = 0  # ⚠️ Check availability first
  # ... other services
}
```

---

## Verifying AMI Availability

### Using AWS CLI

Check if an AMI is available in your region:

```bash
# Check FreeBSD availability
aws ec2 describe-images \
  --region eu-west-1 \
  --owners 118940168514 \
  --filters "Name=name,Values=FreeBSD 13.*-RELEASE-amd64*" \
  --query 'Images[*].[ImageId,Name,CreationDate]' \
  --output table

# Check RHEL9 availability
aws ec2 describe-images \
  --region eu-west-1 \
  --owners 309956199498 \
  --filters "Name=name,Values=RHEL-9.*_HVM-*-x86_64-*" \
  --query 'Images[*].[ImageId,Name,CreationDate]' \
  --output table
```

### Using Terraform Console

```bash
terraform console -var-file=test.tfvars

# Check if AMI data source has results
> data.aws_ami.bsd
> length(data.aws_ami.bsd)
```

---

## Troubleshooting

### Problem: AMI Not Found

**Symptoms**:
- Terraform plan fails with "Your query returned no results"
- Error references specific AMI data source

**Solutions**:
1. Set instance count to 0 for that service
2. Use a different region where the AMI is available
3. Use an alternative service (e.g., Debian instead of FreeBSD)

### Problem: Wrong AMI Version

**Symptoms**:
- AMI found but wrong version
- Incompatible with your configuration

**Solutions**:
1. Update the filter pattern in `main.tf`
2. Pin to specific AMI ID instead of using data source
3. Contact AWS support about AMI availability

---

## Best Practices

1. **Test in Target Region**: Always test your configuration in the target region before production deployment
2. **Use Conditional Lookups**: Keep conditional AMI lookups to avoid unnecessary queries
3. **Document Requirements**: Document which services require which AMIs
4. **Provide Alternatives**: Offer alternative services when AMIs aren't available
5. **Set Safe Defaults**: Default to 0 instances for services with limited AMI availability

---

## Service-to-AMI Mapping

| Service | AMI Type | Required | Alternative |
|---------|----------|----------|-------------|
| adds, adfs, dhcp, etc. | windows2022 | Yes | None |
| sql | sql2019 | Yes | None |
| guacamole, glpi, vault, redis | debian | Yes | None |
| nbu, oracle | rhel9 | Yes | debian (with manual setup) |
| bsd | bsd | No | debian or rhel9 |

---

## Updates

- **2025-01-11**: Initial documentation
- **2025-01-11**: Confirmed BSD not available in eu-west-1
- **2025-01-11**: Updated test.tfvars to disable BSD by default

---

## Related Files

- `main.tf`: AMI data sources (lines 350-410)
- `test.tfvars`: Instance counts configuration
- `locals.tf`: Service definitions with AMI type mappings
- `FIXES-APPLIED.md`: Recent fixes documentation

---

## Support

If you encounter AMI availability issues:
1. Check this document for known issues
2. Verify AMI availability using AWS CLI
3. Update your tfvars to disable unavailable services
4. Consider using alternative regions or services
