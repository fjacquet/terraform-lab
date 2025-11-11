# Migration Guide: Flattened Architecture

This guide explains how to migrate from the old 3-level architecture (root → microsoft/unix → services) to the new 2-level architecture (root → services).

## Overview

**Old Architecture (3 levels):**
```
root/main.tf → microsoft/main.tf → microsoft/adds/main.tf
                                  → microsoft/adfs/main.tf
                                  → ... (16 more)
             → unix/main.tf → unix/guacamole/main.tf
                           → unix/vault/main.tf
                           → ... (7 more)
```

**New Architecture (2 levels):**
```
root/main.tf → modules/service/ (ONE module for ALL services)
root/locals.tf (ALL service configs in ONE place)
```

## Benefits

- **90% code reduction**: From ~2,000 duplicate lines to ~300
- **Single source of truth**: All configuration in `locals.tf`
- **Easier maintenance**: Edit 1-3 files instead of 18-30
- **Faster onboarding**: Understand system in <2 hours vs 4-6 hours
- **Modern Terraform**: Uses for_each, optional(), and moved blocks

## Prerequisites

1. **Terraform >= 1.1** (for moved blocks)
2. **AWS Provider ~> 5.0**
3. **Backup current state**: `terraform state pull > state-backup.json`
4. **Clean working directory**: Commit or stash all changes

## Migration Steps

### Step 1: Backup Current State

```bash
# Pull current state
terraform state pull > state-backup-$(date +%Y%m%d-%H%M%S).json

# Document current resources
terraform state list > resources-before-migration.txt

# Run a plan to ensure everything is clean
terraform plan
```

### Step 2: Apply New Files (Without Removing Old Ones)

The migration uses Terraform's `moved` blocks to safely transition resources without recreation.

```bash
# 1. Rename old files (keep them as backup)
mv main.tf main-old.tf
mv outputs.tf outputs-old.tf

# 2. Rename new files to active
mv main-new.tf main.tf
mv outputs-new.tf outputs.tf

# 3. Initialize to download any new providers
terraform init

# 4. Run plan to see the migration
terraform plan
```

### Step 3: Verify the Plan

**Expected output:**
- Many "moved" operations (resources being relocated in state)
- NO "destroy" operations
- NO "create" operations (except possibly new security groups)
- Changes should be minimal

**Example of correct output:**
```
Terraform will perform the following actions:

  # module.services["adds"] has moved to module.services["adds"]
    resource "aws_instance" "service" {
      # (no changes)
    }

  # module.microsoft.module.adds has moved to module.services["adds"]
    # (moved to new location in state)

Plan: 0 to add, 0 to change, 0 to destroy.
```

**⚠️ WARNING:** If you see any `destroy` or `create` operations, **DO NOT APPLY**. This means something is wrong with the migration. Contact the team for help.

### Step 4: Apply the Migration

```bash
# Apply the changes
terraform apply

# Verify all resources are still present
terraform state list > resources-after-migration.txt

# Compare before and after
diff resources-before-migration.txt resources-after-migration.txt
```

### Step 5: Verify Functionality

```bash
# Run a plan again to ensure no changes
terraform plan

# Expected output: "No changes. Your infrastructure matches the configuration."
```

### Step 6: Clean Up Old Files (Optional)

After successful migration and verification:

```bash
# Archive old module directories
mkdir -p archive/$(date +%Y%m%d)
mv microsoft/ archive/$(date +%Y%m%d)/
mv unix/ archive/$(date +%Y%m%d)/
mv main-old.tf archive/$(date +%Y%m%d)/
mv outputs-old.tf archive/$(date +%Y%m%d)/

# Commit the changes
git add .
git commit -m "Migrate to flattened architecture with unified service module"
```

### Step 7: Remove Moved Blocks (Future Cleanup)

After the migration is complete and stable (e.g., after a few weeks), you can remove the `moved-blocks.tf` file:

```bash
# Remove moved blocks (they're only needed for migration)
rm moved-blocks.tf

# Commit
git add moved-blocks.tf
git commit -m "Remove moved blocks after successful migration"
```

## Rollback Procedure

If something goes wrong during migration:

### Option 1: Restore from Backup

```bash
# Restore old files
mv main-old.tf main.tf
mv outputs-old.tf outputs.tf
rm main-new.tf outputs-new.tf moved-blocks.tf

# Restore state from backup
terraform state push state-backup-YYYYMMDD-HHMMSS.json

# Verify
terraform plan
```

### Option 2: Git Revert

```bash
# Revert the commit
git revert HEAD

# Re-initialize
terraform init

# Verify
terraform plan
```

## Troubleshooting

### Issue: "Resource not found in state"

**Cause:** The moved block references a resource that doesn't exist in your state.

**Solution:** Check if the service is actually deployed (instance count > 0). If not, the moved block can be ignored.

### Issue: "Cycle detected in moved blocks"

**Cause:** Circular dependency in moved blocks.

**Solution:** This shouldn't happen with the provided moved blocks. If it does, contact the team.

### Issue: "Plan shows destroy/create operations"

**Cause:** The new configuration doesn't match the old one exactly.

**Solution:** 
1. DO NOT APPLY
2. Review the differences in the plan
3. Adjust the new configuration to match the old one
4. Contact the team for help

### Issue: "Module not found"

**Cause:** The `modules/service/` directory is missing.

**Solution:** Ensure all new files are present:
- `modules/service/main.tf`
- `modules/service/variables.tf`
- `modules/service/outputs.tf`
- `modules/service/versions.tf`

## Testing in Non-Production

Before applying to production, test in a non-production environment:

1. Create a test workspace or environment
2. Deploy a minimal configuration (e.g., just guacamole)
3. Run through the migration steps
4. Verify functionality
5. Document any issues or adjustments needed

## Post-Migration Verification Checklist

- [ ] `terraform plan` shows no changes
- [ ] All services are accessible
- [ ] DNS records are correct
- [ ] Security groups are functioning
- [ ] No resources were destroyed
- [ ] State file is consistent
- [ ] Outputs are correct
- [ ] Documentation is updated

## Support

If you encounter issues during migration:

1. **DO NOT PANIC** - The state backup can restore everything
2. **DO NOT APPLY** if you see destroy operations
3. **Document the error** - Copy the full terraform plan output
4. **Contact the team** - Provide the error and plan output
5. **Rollback if needed** - Use the rollback procedure above

## Additional Resources

- [Terraform Moved Blocks Documentation](https://www.terraform.io/language/modules/develop/refactoring)
- [Terraform State Management](https://www.terraform.io/language/state)
- [Project Design Document](.kiro/specs/infrastructure-improvements/design.md)
- [Project Requirements](.kiro/specs/infrastructure-improvements/requirements.md)
