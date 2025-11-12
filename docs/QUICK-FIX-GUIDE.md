# Quick Fix Guide - Deprecated Ansible Syntax

## 🔴 Critical Issue #1: become_method Syntax

### Location
`roles/win_laps/tasks/server.yml` - Lines 32, 57, 72

### Current (Deprecated)
```yaml
become: "{{ (opt_laps_domain_server is defined or domain_username is defined) | ternary(omit, True) }}"
become_method: runas  # ❌ DEPRECATED
become_user: SYSTEM
```

### Fixed (Correct)
```yaml
become: "{{ (opt_laps_domain_server is defined or domain_username is defined) | ternary(omit, True) }}"
become_method: ansible.builtin.runas  # ✅ CORRECT
become_user: SYSTEM
```

### Why This Matters
- Ansible now requires Fully Qualified Collection Names (FQCN) for become methods
- Using `runas` without FQCN will fail in newer Ansible versions
- This affects 3 tasks in the win_laps role

---

## 🔴 Critical Issue #2: Removed Module

### Location
`roles/win_laps/tests/setup-domain.yml` - Line 16

### Current (Removed)
```yaml
- name: Setup domain
  ansible.windows.win_domain:  # ❌ REMOVED in ansible.windows 3.0.0
    dns_domain_name: example.com
    safe_mode_password: "{{ admin_password }}"
```

### Fixed (Correct)
```yaml
- name: Setup domain
  microsoft.ad.domain:  # ✅ CORRECT - Use microsoft.ad collection
    dns_domain_name: example.com
    safe_mode_password: "{{ admin_password }}"
```

### Why This Matters
- `ansible.windows.win_domain` was removed in version 3.0.0
- Replaced by `microsoft.ad.domain` in the microsoft.ad collection
- Will cause immediate failure if ansible.windows >= 3.0.0

---

## 🟡 Medium Priority: Platform Versions

### Example: linux_mysql/meta/main.yml

### Current (Invalid)
```yaml
galaxy_info:
  platforms:
    - name: Debian
      versions:
        - 7  # ❌ Not in allowed list
```

### Fixed (Valid)
```yaml
galaxy_info:
  platforms:
    - name: Debian
      versions:
        - all  # ✅ Accepted by Ansible Galaxy
```

### Affected Roles
- linux_apache (Debian 11.3 → all)
- linux_mysql (Debian 7 → all)
- linux_php (Debian 7 → all)
- linux_vault (Debian 8 → all)
- win_chocolatey_server (Windows Server 2016 → all)
- win_laps (Windows 2016 → all)
- win_openssh (Windows 2019 → all)
- win_sus (Windows 2016 → all)

---

## 🟢 Low Priority: Test File Names

### Example: roles/win_adfs/tests/test.yml

### Current (Incorrect)
```yaml
---
- hosts: localhost
  roles:
    - adfs  # ❌ Role not found (directory is win_adfs)
```

### Fixed (Correct)
```yaml
---
- hosts: localhost
  roles:
    - win_adfs  # ✅ Matches directory name
```

### Impact
- Only affects test execution
- 24 test files have this issue
- Can be fixed during regular maintenance

---

## Automated Fix Commands

### Fix Everything Critical (Recommended)
```bash
# This fixes both critical issues automatically
./fix-critical-deprecations.sh
```

### Fix Platform Versions
```bash
# This updates all meta files with correct versions
python3 fix-platform-versions.py
```

### Manual Fix (If You Prefer)
```bash
# Fix become_method
sed -i 's/become_method: runas/become_method: ansible.builtin.runas/g' \
  roles/win_laps/tasks/server.yml

# Fix win_domain module
sed -i 's/ansible\.windows\.win_domain:/microsoft.ad.domain:/g' \
  roles/win_laps/tests/setup-domain.yml

# Install required collection
ansible-galaxy collection install microsoft.ad
```

---

## Verification

### Check Your Fixes
```bash
# Lint specific role
ansible-lint roles/win_laps/

# Lint all roles
ansible-lint roles/

# Check for specific deprecated patterns
grep -r "become_method: runas" roles/
grep -r "ansible.windows.win_domain:" roles/
```

### Expected Output After Fixes
```
✓ No "become_method: runas" found
✓ No "ansible.windows.win_domain" found
✓ ansible-lint shows no critical errors
```

---

## Rollback (If Needed)

All fix scripts create backups:
```bash
# Restore from backups
cp roles/win_laps/tasks/server.yml.bak roles/win_laps/tasks/server.yml
cp roles/win_laps/tests/setup-domain.yml.bak roles/win_laps/tests/setup-domain.yml

# Or use git
git checkout roles/win_laps/
```

---

## Timeline Recommendation

| When | What | Why |
|------|------|-----|
| **Today** | Run `./fix-critical-deprecations.sh` | Prevents immediate failures |
| **This Week** | Run `python3 fix-platform-versions.py` | Ensures Galaxy compatibility |
| **Next Month** | Fix test file names | Only if you use tests |
| **Ongoing** | Run `ansible-lint` before commits | Catch new issues early |

---

## Need Help?

- **Detailed audit**: See `ROLE-DEPRECATION-AUDIT.md`
- **Quick summary**: See `DEPRECATION-AUDIT-SUMMARY.md`
- **This guide**: Quick reference for fixes

All scripts include:
- ✅ Automatic backups
- ✅ Validation checks
- ✅ Clear error messages
- ✅ Rollback instructions
