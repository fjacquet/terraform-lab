# Infrastructure Improvements Spec

## Status: ✅ COMPLETE - Ready for Implementation

This spec defines a comprehensive refactoring of the terraform-lab infrastructure codebase to improve security, maintainability, and code quality while leveraging modern Terraform features.

---

## Quick Links

- **[Requirements](./requirements.md)** - 21 requirements with EARS patterns and INCOSE compliance
- **[Design](./design.md)** - Comprehensive technical design addressing all requirements
- **[Tasks](./tasks.md)** - Active implementation tasks (clean, ready to execute)
- **[Tasks Archive](./tasks-archive.md)** - Completed work (Tasks 1-21)

---

## Overview

### Problem Statement

The terraform-lab codebase (created 6 years ago) suffers from:
- **Code Duplication**: 2,000+ lines of duplicate code across 18+ modules
- **Cognitive Complexity**: 3-level module hierarchy with pass-through layers
- **Maintenance Burden**: Simple changes require editing 18-30 files
- **Outdated Patterns**: Not leveraging modern Terraform features (for_each, moved blocks, optional attributes)

### Solution

Modernize the codebase using Terraform features introduced since 2018:
- **Eliminate duplication** through locals and dynamic blocks
- **Flatten architecture** from 3 levels to 2 levels
- **Consolidate modules** from 18+ to 1 unified module
- **Centralize configuration** in single source of truth

### Expected Impact

- **Code Reduction**: 85% (from ~2,000 to ~300 duplicate lines)
- **Maintenance**: Edit 1-3 files instead of 18-30
- **Onboarding**: Understand system in <2 hours vs 4-6 hours
- **Architecture**: 3 levels → 2 levels (eliminate pass-through layers)

---

## Completed Work ✅

### Phase 1-8 (Tasks 1-18)
- Security hardening (Secrets Manager, IMDSv2, restricted access)
- Code quality (type safety, validation, version constraints)
- Infrastructure enhancements (VPC endpoints, tagging)
- Documentation and tooling (pre-commit hooks, Ansible optimization)

### Phase 9 Partial (Tasks 19-21)
- **Task 19**: Egress rules consolidated in locals (80+ duplicate blocks eliminated)
- **Task 20.1-20.2**: Instance config locals created (metadata_options, root_block_device)
- **Task 21**: AMI data sources consolidated (9 duplicate blocks eliminated)

**Current Progress**: 40% code reduction achieved

---

## Remaining Work 🎯

### Task 20.3: Apply Instance Config Locals (2 hours)
Apply the created locals to all instance resources across all modules.

### Task 22: Flatten Architecture and Modernize (12 hours)
Major refactoring to:
1. Eliminate microsoft/ and unix/ pass-through layers
2. Create ONE unified service module for all services
3. Use for_each to instantiate services from root main.tf
4. Centralize ALL service configuration in root locals.tf
5. Use moved blocks for zero-downtime migration

### Task 26: Create Documentation (4 hours)
Comprehensive documentation including:
- Module README with terraform-docs
- Architecture diagrams (before/after)
- Migration guide with state commands
- Updated root README

**Total Remaining Effort**: ~18 hours

---

## Architecture Transformation

### Before (Current - 3 Levels)
```
root/main.tf
├── module.microsoft (pass-through layer)
│   ├── module.adds
│   ├── module.adfs
│   └── ... (16 more modules)
└── module.unix (pass-through layer)
    ├── module.guacamole
    ├── module.vault
    └── ... (7 more modules)
```

**Problems**:
- 3 levels of indirection
- microsoft/ and unix/ just forward variables
- Configuration scattered across 20+ files
- High cognitive load

### After (Target - 2 Levels)
```
root/main.tf
└── module.services (for_each over all services)
    └── modules/service/ (ONE module for ALL)

root/locals.tf
└── services = { adds = {...}, adfs = {...}, guacamole = {...}, ... }
```

**Benefits**:
- 2 levels (eliminated pass-through layers)
- ALL configuration in ONE file
- ONE module for ALL services
- Low cognitive load

---

## Modern Terraform Features Leveraged

| Feature | Version | Year | Usage |
|---------|---------|------|-------|
| Module for_each | Terraform 0.13 | 2020 | Instantiate modules dynamically |
| moved blocks | Terraform 1.1 | 2021 | Safe refactoring without resource recreation |
| optional() attributes | Terraform 1.3 | 2022 | Flexible object types with defaults |
| defaults() function | Terraform 1.6 | 2023 | Merge configs with defaults |
| Provider default_tags | AWS Provider 3.38 | 2021 | No need to repeat tags |

---

## Requirements Coverage

All 21 requirements are addressed:

### Security (Requirements 1, 2, 16, 18)
- Secrets Manager integration
- IMDSv2 enforcement
- Restricted security group access
- Security group rule descriptions

### Code Quality (Requirements 3, 4, 5, 9, 17, 19, 21)
- Version constraints
- DRY principle (locals, consolidation)
- Type safety and validation
- Code cleanup
- KISS principle (simplified architecture)

### Infrastructure (Requirements 7, 8, 10, 15)
- Default tags at provider level
- Region parameterization
- VPC endpoints
- State management

### Operations (Requirements 6, 11, 12, 13, 14, 20)
- PowerShell error handling
- Ansible optimization
- Module documentation
- Pre-commit hooks
- Backward compatibility

---

## How to Use This Spec

### For Implementation

1. **Start with Task 20.3**: Low-risk, high-impact (2 hours)
2. **Then Task 22**: Major refactoring (12 hours)
3. **Finish with Task 26**: Documentation (4 hours)

### For Review

1. Read **requirements.md** to understand what needs to be achieved
2. Read **design.md** to understand how it will be achieved
3. Read **tasks.md** to see the implementation plan
4. Check **tasks-archive.md** to see what's already done

### For Reference

- **Design decisions**: See "Design Decisions and Rationale" in design.md
- **Testing strategy**: See "Testing Strategy" in design.md
- **Migration approach**: See "Migration Strategy" in design.md
- **Rollback procedures**: See "Rollback Plan" in design.md

---

## Success Criteria

- [ ] No duplicate egress rules across security groups
- [ ] No duplicate instance configuration blocks
- [ ] AMI lookups centralized in parent modules
- [ ] Service configuration in single location
- [ ] Module structure simplified (2 levels instead of 3)
- [ ] ONE service module instead of 18+
- [ ] New team member can understand system in < 2 hours
- [ ] Common changes require editing 1-3 files maximum
- [ ] All existing functionality maintained
- [ ] Zero resource recreation during migration
- [ ] Comprehensive documentation with examples

---

## Next Steps

1. **Open tasks.md** in your IDE
2. **Click "Start task"** next to Task 20.3
3. **Follow the implementation plan** phase by phase
4. **Test thoroughly** at each phase
5. **Update documentation** as you go

---

## Questions or Issues?

- Review the **design.md** for detailed technical decisions
- Check **tasks-archive.md** for completed work examples
- Refer to **requirements.md** for acceptance criteria
- See "Troubleshooting" section in design.md

---

**Spec Created**: 2024
**Last Updated**: 2024
**Status**: Complete and ready for implementation
**Estimated Effort**: 18 hours remaining
**Expected Impact**: 85% code reduction, dramatically improved maintainability
