# Role Deprecation Audit Report

**Date**: November 12, 2025  
**Project**: terraform-lab  
**Auditor**: Kiro AI Assistant

## Executive Summary

This audit identifies deprecated Ansible modules, syntax, and practices across all roles in the terraform-lab project. Most critical deprecations have been addressed in previous fixes, but several issues remain that require attention.

## Status Overview

- ✅ **Fixed**: Deprecated modules replaced (win_domain, win_domain_controller, win_domain_membership)
- ✅ **Fixed**: Loop syntax modernized (with_flattened → loop with flatten)
- ✅ **Fixed**: Command module replaced with proper modules (touch → file)
- ✅ **Fixed**: Outdated noqa tags replaced with named tags
- ⚠️ **Remaining**: become_method syntax needs FQCN
- ⚠️ **Remaining**: Platform version validation issues in meta files
- ⚠️ **Remaining**: Test file role name mismatches
- ⚠️ **Remaining**: Jinja template syntax errors in molecule files

## Critical Issues Requiring Immediate Attention

### 1. Deprecated become_method Syntax (3 occurrences)

**Location**: `roles/win_laps/tasks/server.yml` (lines 32, 57, 72)

**Issue**: Using `become_method: runas` instead of FQCN `ansible.builtin.runas`

**Current Code**:

```yaml
become_method: runas
```

**Required Fix**:

```yaml
become_method: ansible.builtin.runas
```

**Impact**: Major - Will fail in future Ansible versions
**Priority**: High

### 2. Deprecated Module in Test File

**Location**: `roles/win_laps/tests/setup-domain.yml` (line 16)

**Issue**: Using removed `ansible.windows.win_domain` module

**Current Code**:

```yaml
- name: Setup domain
  ansible.windows.win_domain:
    # ...
```

**Required Fix**:

```yaml
- name: Setup domain
  microsoft.ad.domain:
    # ...
```

**Impact**: Major - Module removed in ansible.windows 3.0.0
**Priority**: High

## Schema Validation Issues

### Platform Version Mismatches

Several roles have platform versions that don't match Ansible Galaxy's allowed values:

| Role | File | Issue | Allowed Values |
|------|------|-------|----------------|
| linux_apache | meta/main.yml | Version '11.3' for Debian | '6.1', '7.1', '7.2', 'all' |
| linux_mysql | meta/main.yml | Version '7' for Debian | '6.1', '7.1', '7.2', 'all' |
| linux_php | meta/main.yml | Version '7' for Debian | '6.1', '7.1', '7.2', 'all' |
| linux_vault | meta/main.yml | Version '8' for Debian | '6.1', '7.1', '7.2', 'all' |
| win_chocolatey_server | meta/main.yml | Version 'Server 2016' | '6.1', '7.1', '7.2', 'all' |
| win_laps | meta/main.yml | Version '2016' | '6.1', '7.1', '7.2', 'all' |
| win_openssh | meta/main.yml | Version '2019' | '6.1', '7.1', '7.2', 'all' |
| win_sus | meta/main.yml | Version '2016' | '6.1', '7.1', '7.2', 'all' |

**Recommendation**: Use 'all' for broader compatibility or update to match actual OS versions being targeted.

## Test File Issues

### Role Name Mismatches (24 occurrences)

Test files reference role names that don't match the actual role directory names. This causes syntax check failures.

**Pattern**: `roles/*/tests/test.yml` files use short names instead of full role names

**Examples**:

- `roles/debian_glpi/tests/test.yml` references `glpi` instead of `debian_glpi`
- `roles/win_adfs/tests/test.yml` references `adfs` instead of `win_adfs`
- `roles/win_domain_pdc/tests/test.yml` references `domain_pdc` instead of `win_domain_pdc`

**Impact**: Minor - Only affects test execution
**Priority**: Low (unless tests are actively used)

## Jinja Template Errors

### Molecule Create Files (2 roles)

**Locations**:

- `roles/rhel_server/molecule/default/create.yml` (line 14)
- `roles/win_simpana_server/molecule/default/create.yml` (line 14)

**Issue**: Empty Jinja print statements causing syntax errors

**Error**: "Expected an expression, got 'end of print statement'"

**Impact**: Minor - Only affects molecule testing
**Priority**: Low (unless molecule tests are actively used)

## Style and Best Practice Issues

### 1. Jinja Templates in Task Names (2 occurrences)

**Locations**:

- `roles/win_openssh/tasks/service.yml` (line 16)
- `roles/win_server/tasks/locale.yml` (line 2)

**Issue**: Jinja templates should only be at the end of task names

**Current**:

```yaml
- name: open port {{ opt_openssh_port }} for inbound SSH connections
```

**Better**:

```yaml
- name: Open port for inbound SSH connections ({{ opt_openssh_port }})
```

**Impact**: Minor - Style issue
**Priority**: Low

### 2. Tab Characters in YAML

**Location**: `roles/win_openssh/tests/custom_vars.yml` (line 97)

**Issue**: YAML files should use spaces, not tabs

**Impact**: Minor - Formatting issue
**Priority**: Low

## Previously Fixed Issues ✅

The following deprecations have been successfully addressed:

1. **Deprecated Domain Modules** (3 files fixed)
   - `ansible.windows.win_domain` → `microsoft.ad.domain`
   - `ansible.windows.win_domain_controller` → `microsoft.ad.domain_controller`
   - `ansible.windows.win_domain_membership` → `microsoft.ad.membership`

2. **Loop Syntax** (1 file fixed)
   - `with_flattened` → `loop` with `flatten` filter
   - File: `roles/linux_php/tasks/configure.yml`

3. **Command Module Misuse** (2 tasks fixed)
   - `command: touch` → `ansible.builtin.file` with `state: touch`
   - File: `roles/linux_mysql/tasks/configure.yml`

4. **Outdated noqa Tags** (3 occurrences fixed)
   - Tag `208` → `risky-file-permissions`
   - File: `roles/linux_php/tasks/install-from-source.yml`

5. **Schema Issues** (39 files fixed)
   - `min_ansible_version` converted from number to string in all meta files

6. **Empty Register Statement** (1 file fixed)
   - Removed invalid empty `register:` statement
   - File: `roles/rhel_server/tasks/main.yml`

## Recommendations

### Immediate Actions (High Priority)

1. **Fix become_method in win_laps role**

   ```bash
   # Update roles/win_laps/tasks/server.yml
   sed -i 's/become_method: runas/become_method: ansible.builtin.runas/g' roles/win_laps/tasks/server.yml
   ```

2. **Fix deprecated module in win_laps test**

   ```bash
   # Update roles/win_laps/tests/setup-domain.yml
   sed -i 's/ansible.windows.win_domain:/microsoft.ad.domain:/g' roles/win_laps/tests/setup-domain.yml
   ```

3. **Verify microsoft.ad collection is installed**

   ```bash
   ansible-galaxy collection install microsoft.ad
   ```

### Medium Priority Actions

1. **Update platform versions in meta files**
   - Review each role's target platforms
   - Update versions to 'all' or specific supported versions
   - Ensure consistency across similar roles

2. **Fix test file role names** (if tests are used)
   - Update all `roles/*/tests/test.yml` files
   - Change role references to match directory names
   - Or create symlinks for backward compatibility

### Low Priority Actions

1. **Fix Jinja template positioning in task names**
   - Move variables to end of task names
   - Improves readability and follows best practices

2. **Remove tabs from YAML files**
   - Convert tabs to spaces in `roles/win_openssh/tests/custom_vars.yml`

3. **Fix molecule template errors** (if molecule is used)
   - Review and fix empty Jinja expressions
   - Test molecule scenarios after fixes

## Verification Commands

After applying fixes, run these commands to verify:

```bash
# Check for remaining deprecated syntax
ansible-lint roles/win_laps/

# Validate all roles
ansible-lint roles/

# Check specific issues
ansible-lint --parseable roles/ | grep -E "(become_method|win_domain|with_flattened)"

# Verify collection availability
ansible-galaxy collection list | grep microsoft.ad
```

## Dependencies

Ensure these collections are installed and up-to-date:

```yaml
# requirements.yml
collections:
  - name: microsoft.ad
    version: ">=1.0.0"
  - name: ansible.windows
    version: ">=3.0.0"
  - name: community.general
    version: ">=8.0.0"
```

## Impact Assessment

| Category | Count | Severity | Blocking |
|----------|-------|----------|----------|
| Critical Deprecations | 4 | High | Yes |
| Schema Issues | 8 | Medium | No |
| Test Issues | 24 | Low | No |
| Style Issues | 3 | Low | No |
| **Total Issues** | **39** | - | - |
| **Previously Fixed** | **48** | - | - |

## Conclusion

The project has made significant progress in addressing deprecated Ansible syntax and modules. The remaining issues are primarily:

1. **4 critical deprecations** requiring immediate attention (become_method and test file)
2. **8 schema validation issues** that should be addressed for Galaxy compatibility
3. **27 minor issues** that can be addressed as time permits

**Recommended Timeline**:

- Critical fixes: Within 1 week
- Schema fixes: Within 1 month
- Minor fixes: As time permits or during regular maintenance

## References

- [Ansible Lint Rules](https://ansible.readthedocs.io/projects/lint/rules/)
- [Microsoft AD Collection](https://docs.ansible.com/ansible/latest/collections/microsoft/ad/)
- [Ansible Windows Collection Changelog](https://github.com/ansible-collections/ansible.windows/blob/main/CHANGELOG.rst)
- [Ansible Best Practices](https://docs.ansible.com/ansible/latest/user_guide/playbooks_best_practices.html)
