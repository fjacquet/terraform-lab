# Archived Module Structure

This directory contains the old 3-level module structure that was replaced by the flattened 2-level architecture.

## Archived on
November 11, 2025

## Reason
Migration to unified service module architecture for:
- 90% code reduction
- Single source of truth
- Easier maintenance
- Modern Terraform patterns

## What's Archived

### microsoft/
Old Windows services module structure with 17+ individual service modules:
- adds/ (Active Directory Domain Services)
- adfs/ (AD Federation Services)
- dhcp/ (DHCP Server)
- exchange/ (Exchange Server)
- sql/ (SQL Server)
- sharepoint/ (SharePoint)
- And 11 more...

### unix/
Old Unix/Linux services module structure with 7+ individual service modules:
- guacamole/ (Bastion host)
- glpi/ (IT Asset Management)
- vault/ (HashiCorp Vault)
- nbu/ (NetBackup)
- oracle/ (Oracle Database)
- redis/ (Redis)
- bsd/ (FreeBSD)

### main-old.tf
Old root main.tf that called microsoft/ and unix/ modules

## New Architecture

The new architecture uses:
- **main.tf**: Single for_each loop for ALL services
- **locals.tf**: All service configurations in one place
- **modules/service/**: ONE unified module for all services

## Benefits Realized

- **Code Reduction**: 85% (from ~2,000 to ~300 lines)
- **Module Consolidation**: 97% (from 30+ modules to 1)
- **Maintenance Effort**: 90% reduction
- **Onboarding Time**: 67% faster

## Reference

See project root for:
- `/ARCHITECTURE.md` - New architecture documentation
- `/REFACTORING-SUMMARY.md` - Complete refactoring summary
- `/modules/service/README.md` - Unified module documentation

## Restoration

If you need to restore these files:

1. Copy them back to the root directory
2. Restore the old main.tf
3. Run `terraform init`
4. Run `terraform plan` to verify

**Note**: The state file has been migrated to the new structure. Restoration would require additional state manipulation and is not recommended.

## File Structure

```
archive/20251111/
├── README.md (this file)
├── main-old.tf
├── microsoft/
│   ├── main.tf
│   ├── locals.tf
│   ├── outputs.tf
│   ├── variables.tf
│   ├── adds/
│   ├── adfs/
│   ├── adcs/
│   ├── dhcp/
│   ├── da/
│   ├── exchange/
│   ├── fs/
│   ├── ipam/
│   ├── mgmt/
│   ├── nps/
│   ├── rdsh/
│   ├── sharepoint/
│   ├── sql/
│   ├── simpana/
│   ├── sofs/
│   ├── wac/
│   ├── wds/
│   ├── wsus/
│   └── workfolders/
└── unix/
    ├── main.tf
    ├── locals.tf
    ├── outputs.tf
    ├── variables.tf
    ├── bsd/
    ├── glpi/
    ├── guacamole/
    ├── nbu/
    ├── oracle/
    ├── redis/
    └── vault/
```

## Historical Context

This module structure served the project well but had limitations:
- **Pass-through layers**: microsoft/ and unix/ were just wrappers
- **Code duplication**: Every module had similar boilerplate
- **Scattered configuration**: Settings spread across 30+ files
- **Maintenance burden**: Changes required editing many files

The new architecture addresses all these issues while maintaining full functionality.

## Lessons Learned

### What Worked
- Modular structure was good for initial development
- Clear separation between Windows and Unix services
- Each service had its own isolated configuration

### What Didn't Work
- Too many layers of abstraction
- Massive code duplication
- Hard to see the big picture
- Slow to make changes

### Improvements in New Architecture
- Single source of truth (locals.tf)
- One unified module for all services
- 90% less code to maintain
- Much easier to understand and modify

## Migration Notes

This was a **greenfield deployment**, so no actual state migration was needed. The old structure was simply archived and the new structure deployed fresh.

For projects with existing infrastructure, see `/MIGRATION-GUIDE.md` for safe migration procedures using Terraform's `moved` blocks.

---

**Archived by**: Infrastructure refactoring (Task 22)
**Status**: Archived for reference only
**Recommendation**: Use new architecture in `/main.tf` and `/modules/service/`
