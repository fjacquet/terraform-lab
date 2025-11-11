# Migration Guide

This guide provides step-by-step instructions for upgrading your terraform-lab infrastructure to the latest version with enhanced security, maintainability, and best practices.

## Overview of Changes

The infrastructure improvements include:

1. **Security Enhancements**
   - Restricted administrative access via `admin_cidr_blocks`
   - AWS Secrets Manager integration
   - IMDSv2 enforcement on all EC2 instances
   - VPC endpoints for AWS services

2. **Code Quality Improvements**
   - Reduced code duplication through locals
   - Enhanced variable validation
   - Improved error handling in PowerShell scripts

3. **Infrastructure Enhancements**
   - VPC endpoints for SSM, Secrets Manager, EC2 Messages
   - Standardized resource tagging
   - Region parameterization

## Pre-Migration Checklist

Before starting the migration, complete these steps:

- [ ] Review all changes in the [design document](.kiro/specs/infrastructure-improvements/design.md)
- [ ] Back up your current Terraform state file
- [ ] Export current infrastructure configuration
- [ ] Document any custom modifications
- [ ] Test migration in a non-production environment first
- [ ] Schedule maintenance window for production migration
- [ ] Notify stakeholders of planned changes

## Migration Steps

### Step 1: Backup Current State

```bash
# Pull current state
terraform state pull > terraform-state-backup-$(date +%Y%m%d-%H%M%S).json

# Export current infrastructure
terraform show > terraform-current-$(date +%Y%m%d-%H%M%S).txt

# Backup variable files
cp terraform.tfvars terraform.tfvars.backup
cp variables.tf variables.tf.backup
```

### Step 2: Update Repository

```bash
# Fetch latest changes
git fetch origin

# Create migration branch
git checkout -b migration-infrastructure-improvements

# Pull latest code
git pull origin main
```

### Step 3: Review New Variables

The following new variables have been added. Review and configure them:

#### admin_cidr_blocks

**Purpose**: Controls administrative access to RDP, SSH, and WinRM

**Default**: `["10.0.0.0/16"]` (VPC CIDR only)

**Action Required**: Update to match your security requirements

```hcl
# Example: Corporate office and VPN access
admin_cidr_blocks = [
  "203.0.113.0/24",    # Corporate office
  "198.51.100.0/24"    # VPN endpoint
]
```

#### enable_public_admin_access

**Purpose**: Emergency override for public administrative access

**Default**: `false`

**Action Required**: Keep as `false` for production

```hcl
# Only set to true for temporary troubleshooting
enable_public_admin_access = false
```

### Step 4: Create AWS Secrets

Before applying infrastructure changes, create required secrets in AWS Secrets Manager:

```bash
# Create local administrator password
aws secretsmanager create-secret \
    --name "ez-lab.xyz/ansible/localadmin" \
    --description "Local administrator password for Windows instances" \
    --secret-string "$(openssl rand -base64 32)" \
    --region YOUR_REGION

# Create domain join credentials
aws secretsmanager create-secret \
    --name "ezlab/ad/joinuser" \
    --description "Domain join credentials" \
    --secret-string '{"username":"domain-join-user","password":"YOUR_SECURE_PASSWORD"}' \
    --region YOUR_REGION

# Create other required secrets (see README.md for full list)
```

**Verify secrets creation:**

```bash
aws secretsmanager list-secrets --region YOUR_REGION | grep -E "ez-lab|ezlab"
```

### Step 5: Update Terraform Configuration

#### 5.1 Update variables.tf (if customized)

If you have a custom `terraform.tfvars` file, add the new variables:

```hcl
# Add to terraform.tfvars
admin_cidr_blocks = ["YOUR_CIDR_BLOCKS"]
enable_public_admin_access = false
```

#### 5.2 Review locals.tf

The new `locals.tf` file contains computed values. Review but do not modify unless you have specific requirements.

### Step 6: Initialize and Plan

```bash
# Re-initialize Terraform (downloads updated providers)
terraform init -upgrade

# Validate configuration
terraform validate

# Generate execution plan
terraform plan -out=migration.tfplan

# Review the plan carefully
terraform show migration.tfplan > migration-plan-$(date +%Y%m%d-%H%M%S).txt
```

### Step 7: Review Plan Output

**Expected Changes:**

1. **Security Groups**: Modified to use new CIDR block variables
2. **EC2 Instances**: Modified to add IMDSv2 metadata options
3. **VPC Endpoints**: New resources created (SSM, Secrets Manager, EC2 Messages)
4. **Tags**: Updated on existing resources

**Unexpected Changes to Investigate:**

- Resource replacements (should be minimal)
- Resource deletions (should be none)
- Changes to production data resources

**Critical**: If you see unexpected resource deletions or replacements, STOP and investigate before proceeding.

### Step 8: Apply Changes

```bash
# Apply the migration plan
terraform apply migration.tfplan

# Monitor the output for errors
```

**Expected Duration**: 10-20 minutes depending on infrastructure size

### Step 9: Verify Infrastructure

After applying changes, verify the infrastructure:

```bash
# Check VPC endpoints
aws ec2 describe-vpc-endpoints --region YOUR_REGION

# Verify security group rules
aws ec2 describe-security-groups --region YOUR_REGION \
    --filters "Name=tag:Project,Values=terraform-lab"

# Test instance metadata service (from an EC2 instance)
# This should require IMDSv2 token
TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" \
    -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
curl -H "X-aws-ec2-metadata-token: $TOKEN" \
    http://169.254.169.254/latest/meta-data/instance-id
```

### Step 10: Test Connectivity

Verify administrative access still works:

```bash
# Test SSH access (Linux instances)
ssh -i ~/.ssh/aws admin@YOUR_INSTANCE_IP

# Test RDP access (Windows instances)
# Use Remote Desktop client to connect

# Test WinRM (from Ansible control node)
ansible windows -m win_ping
```

### Step 11: Update Ansible Configuration

The Ansible configuration has been optimized. Verify it works:

```bash
# Test dynamic inventory
ansible-inventory -i inventory/aws_ec2.yaml --list

# Run a simple playbook
ansible-playbook playbooks/system/configure-linux.yml --check
```

### Step 12: Commit Changes

```bash
# Add migration notes
git add .
git commit -m "Migrate to infrastructure improvements

- Added security variables for admin access control
- Integrated AWS Secrets Manager
- Enforced IMDSv2 on all instances
- Added VPC endpoints for AWS services
- Reduced code duplication with locals"

# Push to repository
git push origin migration-infrastructure-improvements
```

## Variable Changes Reference

### New Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `admin_cidr_blocks` | `list(string)` | `["10.0.0.0/16"]` | CIDR blocks for admin access |
| `enable_public_admin_access` | `bool` | `false` | Allow public admin access |

### Modified Variables

| Variable | Old Type | New Type | Migration Notes |
|----------|----------|----------|-----------------|
| `aws_number` | `map(string)` | `map(number)` | Automatic conversion, no action needed |
| `cidrbyte` | `map(string)` | `map(number)` | Automatic conversion, no action needed |

### Removed Variables

None. All existing variables are maintained for backward compatibility.

## Rollback Procedures

If you encounter issues during migration, follow these rollback steps:

### Option 1: Rollback via Git

```bash
# Revert to previous commit
git revert HEAD

# Re-initialize and apply
terraform init
terraform plan
terraform apply
```

### Option 2: Restore from State Backup

```bash
# Stop any running Terraform operations
# Restore state file
terraform state push terraform-state-backup-TIMESTAMP.json

# Verify state
terraform state list

# Plan to verify
terraform plan
```

### Option 3: Targeted Rollback

If only specific resources are problematic:

```bash
# Remove problematic resource from state
terraform state rm aws_vpc_endpoint.ssm

# Re-import if needed
terraform import aws_vpc_endpoint.ssm vpce-xxxxx

# Or destroy and recreate
terraform destroy -target=aws_vpc_endpoint.ssm
terraform apply -target=aws_vpc_endpoint.ssm
```

## Post-Migration Tasks

After successful migration:

1. **Update Documentation**
   - Document any custom configurations
   - Update runbooks with new procedures
   - Share migration experience with team

2. **Monitor Infrastructure**
   - Check CloudWatch metrics for anomalies
   - Review VPC Flow Logs
   - Monitor Secrets Manager access logs
   - Verify cost impact of VPC endpoints

3. **Security Audit**
   - Verify security group rules are correct
   - Confirm IMDSv2 is enforced
   - Test secret rotation
   - Review IAM permissions

4. **Clean Up**
   - Remove backup files after verification period
   - Delete migration branch after merge
   - Archive migration documentation

## Troubleshooting

### Issue: Terraform Plan Shows Unexpected Changes

**Symptom**: Plan shows resource replacements or deletions

**Solution**:
1. Review the specific resources being changed
2. Check if moved blocks are needed
3. Verify variable values match previous configuration
4. Use `terraform state show` to inspect current state

### Issue: Security Group Rules Not Working

**Symptom**: Cannot connect via RDP/SSH after migration

**Solution**:
1. Verify `admin_cidr_blocks` includes your IP
2. Check `enable_public_admin_access` setting
3. Review security group rules in AWS Console
4. Verify network ACLs haven't changed

### Issue: Secrets Manager Access Denied

**Symptom**: EC2 instances cannot retrieve secrets

**Solution**:
1. Verify IAM instance profile has Secrets Manager permissions
2. Check VPC endpoint for Secrets Manager is working
3. Verify secret names match exactly
4. Review CloudTrail logs for access attempts

### Issue: IMDSv2 Breaking Scripts

**Symptom**: User data scripts or applications fail

**Solution**:
1. Update scripts to use IMDSv2 token-based authentication
2. Check `http_put_response_hop_limit` setting
3. Verify applications support IMDSv2
4. Review instance logs for metadata access errors

### Issue: VPC Endpoints Not Working

**Symptom**: Services cannot reach AWS APIs

**Solution**:
1. Verify VPC endpoint security groups allow HTTPS (443)
2. Check route tables include VPC endpoint routes
3. Verify private DNS is enabled
4. Test connectivity from instance

## Getting Help

If you encounter issues not covered in this guide:

1. Review the [design document](.kiro/specs/infrastructure-improvements/design.md)
2. Check the [security documentation](SECURITY.md)
3. Review Terraform and AWS documentation
4. Open an issue in the repository with:
   - Migration step where issue occurred
   - Error messages
   - Terraform version
   - AWS provider version
   - Relevant logs

## Migration Timeline

Recommended timeline for production migration:

- **Week 1**: Review changes, test in development
- **Week 2**: Test in staging environment
- **Week 3**: Plan production migration, create secrets
- **Week 4**: Execute production migration during maintenance window
- **Week 5**: Monitor and optimize

## Success Criteria

Migration is considered successful when:

- [ ] All Terraform apply operations complete without errors
- [ ] No unexpected resource changes or deletions
- [ ] Administrative access (RDP/SSH/WinRM) works correctly
- [ ] All EC2 instances enforce IMDSv2
- [ ] Secrets Manager integration works for all services
- [ ] VPC endpoints are operational
- [ ] Ansible playbooks execute successfully
- [ ] No increase in AWS costs beyond VPC endpoint charges
- [ ] All monitoring and alerting continues to function
- [ ] Team is trained on new security variables
