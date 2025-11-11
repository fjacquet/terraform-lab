# Cleanup Instructions

After successful migration to the flattened architecture, follow these steps to clean up the old module directories.

## ⚠️ Important: Only perform cleanup AFTER successful migration

Do not remove old directories until:
1. Migration is complete and tested
2. `terraform plan` shows no changes
3. All services are functioning correctly
4. You have verified the new architecture for at least 1-2 weeks

## Step 1: Archive Old Module Directories

Instead of deleting, archive the old directories for reference:

```bash
# Create archive directory with timestamp
mkdir -p archive/$(date +%Y%m%d)

# Move old module directories to archive
mv microsoft/ archive/$(date +%Y%m%d)/
mv unix/ archive/$(date +%Y%m%d)/

# Move old main and outputs files
mv main-old.tf archive/$(date +%Y%m%d)/ 2>/dev/null || true
mv outputs-old.tf archive/$(date +%Y%m%d)/ 2>/dev/null || true

# Create README in archive
cat > archive/$(date +%Y%m%d)/README.md << 'EOF'
# Archived Module Structure

This directory contains the old 3-level module structure that was replaced
by the flattened 2-level architecture.

## Archived on
$(date)

## Reason
Migration to unified service module architecture for:
- 90% code reduction
- Single source of truth
- Easier maintenance
- Modern Terraform patterns

## Reference
See /ARCHITECTURE.md and /MIGRATION-GUIDE.md for details on the new architecture.

## Restoration
If you need to restore these files:
1. Copy them back to the root directory
2. Restore the old main.tf and outputs.tf
3. Run `terraform init`
4. Run `terraform plan` to verify

Note: The state file has been migrated, so restoration may require
additional state manipulation.
EOF
```

## Step 2: Update .gitignore (Optional)

Add the archive directory to .gitignore if you don't want to commit it:

```bash
echo "archive/" >> .gitignore
```

Or commit it for historical reference:

```bash
git add archive/
git commit -m "Archive old module structure after migration"
```

## Step 3: Remove Moved Blocks (After Stabilization)

After the migration has been stable for a few weeks, you can remove the moved blocks:

```bash
# Remove moved-blocks.tf
rm moved-blocks.tf

# Commit
git add moved-blocks.tf
git commit -m "Remove moved blocks after successful migration stabilization"
```

## Step 4: Update Documentation

Ensure all documentation references the new architecture:

- [ ] Update README.md to reference new structure
- [ ] Update any deployment guides
- [ ] Update team documentation
- [ ] Update CI/CD pipelines if needed

## Step 5: Clean Up Temporary Files

Remove any temporary files created during migration:

```bash
# Remove backup state files (after verifying migration)
rm state-backup-*.json

# Remove resource lists
rm resources-before-migration.txt
rm resources-after-migration.txt

# Remove any test files
rm test-*.tf 2>/dev/null || true
```

## What NOT to Delete

Do not delete these files - they are part of the new architecture:

- `main.tf` (new flattened main file)
- `locals.tf` (service configurations)
- `outputs.tf` (new outputs file)
- `modules/service/` (unified service module)
- `ARCHITECTURE.md` (architecture documentation)
- `MIGRATION-GUIDE.md` (migration instructions)

## Verification After Cleanup

After cleanup, verify everything still works:

```bash
# Verify Terraform configuration
terraform validate

# Verify no changes needed
terraform plan

# Expected output: "No changes. Your infrastructure matches the configuration."
```

## Rollback After Cleanup

If you need to rollback after cleanup:

1. **Restore from archive**:
```bash
cp -r archive/YYYYMMDD/microsoft/ .
cp -r archive/YYYYMMDD/unix/ .
cp archive/YYYYMMDD/main-old.tf main.tf
cp archive/YYYYMMDD/outputs-old.tf outputs.tf
```

2. **Restore state** (if needed):
```bash
terraform state push state-backup-YYYYMMDD-HHMMSS.json
```

3. **Verify**:
```bash
terraform init
terraform plan
```

## Archive Retention Policy

Recommended retention:
- **Keep archives for at least 6 months** after migration
- **Keep state backups for at least 1 year**
- **Document the migration** in team knowledge base

## Questions?

If you have questions about cleanup:
1. Review ARCHITECTURE.md for new structure
2. Review MIGRATION-GUIDE.md for migration details
3. Contact the infrastructure team
4. Check git history for migration commit

## Cleanup Checklist

- [ ] Migration completed successfully
- [ ] Verified with `terraform plan` (no changes)
- [ ] All services functioning correctly
- [ ] Waited 1-2 weeks for stabilization
- [ ] Created archive directory
- [ ] Moved old directories to archive
- [ ] Created archive README
- [ ] Updated .gitignore or committed archive
- [ ] Removed moved-blocks.tf (after stabilization)
- [ ] Updated documentation
- [ ] Cleaned up temporary files
- [ ] Verified Terraform still works
- [ ] Documented cleanup in team knowledge base
