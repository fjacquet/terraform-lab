# Deprecation Audit Summary

## Quick Overview

Your Ansible roles have been audited for deprecated modules and syntax. Most critical issues were already fixed in previous work, but **4 critical issues remain** that need immediate attention.

## Critical Issues (Fix Now) 🔴

### 1. Invalid become_method Syntax
- **File**: `roles/win_laps/tasks/server.yml`
- **Lines**: 32, 57, 72
- **Issue**: Using `become_method: runas` instead of `ansible.builtin.runas`
- **Fix**: Run `./fix-critical-deprecations.sh`

### 2. Removed Module in Test
- **File**: `roles/win_laps/tests/setup-domain.yml`
- **Line**: 16
- **Issue**: Using removed `ansible.windows.win_domain` module
- **Fix**: Run `./fix-critical-deprecations.sh`

## Medium Priority Issues (Fix Soon) 🟡

### Platform Version Mismatches (8 roles)
Roles have platform versions that don't match Ansible Galaxy's allowed values:
- linux_apache, linux_mysql, linux_php, linux_vault
- win_chocolatey_server, win_laps, win_openssh, win_sus

**Fix**: Run `python3 fix-platform-versions.py`

## Low Priority Issues (Fix When Convenient) 🟢

### Test File Role Names (24 files)
Test files reference short role names instead of full directory names.
- Only affects test execution
- Can be fixed during regular maintenance

### Style Issues (3 files)
- Jinja templates in middle of task names (2 files)
- Tab characters in YAML (1 file)

## What's Already Fixed ✅

Great news! These deprecations were already addressed:
- ✅ Deprecated domain modules (win_domain → microsoft.ad.domain)
- ✅ Loop syntax (with_flattened → loop with flatten)
- ✅ Command module misuse (touch → file module)
- ✅ Outdated noqa tags (208 → risky-file-permissions)
- ✅ Schema issues (min_ansible_version as string)

## Quick Fix Commands

```bash
# Fix critical issues (takes ~10 seconds)
./fix-critical-deprecations.sh

# Fix platform versions (takes ~5 seconds)
python3 fix-platform-versions.py

# Verify all fixes
ansible-lint roles/
```

## Files Created

1. **ROLE-DEPRECATION-AUDIT.md** - Detailed audit report with all findings
2. **fix-critical-deprecations.sh** - Script to fix critical issues
3. **fix-platform-versions.py** - Script to fix platform version issues
4. **DEPRECATION-AUDIT-SUMMARY.md** - This quick reference guide

## Impact Assessment

| Priority | Count | Blocking | Timeline |
|----------|-------|----------|----------|
| Critical | 4 | Yes | Fix today |
| Medium | 8 | No | Fix this week |
| Low | 27 | No | Fix when convenient |

## Dependencies Required

Ensure you have the microsoft.ad collection:
```bash
ansible-galaxy collection install microsoft.ad
```

## Next Steps

1. **Now**: Run `./fix-critical-deprecations.sh`
2. **This week**: Run `python3 fix-platform-versions.py`
3. **Later**: Review and fix test files if you use them
4. **Always**: Run `ansible-lint` before committing changes

## Questions?

See **ROLE-DEPRECATION-AUDIT.md** for detailed information about each issue, including:
- Exact line numbers and code examples
- Before/after comparisons
- Impact analysis
- Verification commands
