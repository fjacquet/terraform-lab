#!/usr/bin/env python3
"""
Fix Platform Version Issues in Role Meta Files

This script updates platform versions in meta/main.yml files to use 'all'
instead of specific versions that don't match Ansible Galaxy's allowed values.
"""

import os
import yaml
from pathlib import Path

# Roles with platform version issues
ROLES_TO_FIX = {
    'linux_apache': {'platform': 'Debian', 'old_version': '11.3', 'new_version': 'all'},
    'linux_mysql': {'platform': 'Debian', 'old_version': '7', 'new_version': 'all'},
    'linux_php': {'platform': 'Debian', 'old_version': '7', 'new_version': 'all'},
    'linux_vault': {'platform': 'Debian', 'old_version': '8', 'new_version': 'all'},
    'win_chocolatey_server': {'platform': 'Windows', 'old_version': 'Server 2016', 'new_version': 'all'},
    'win_laps': {'platform': 'Windows', 'old_version': 2016, 'new_version': 'all'},
    'win_openssh': {'platform': 'Windows', 'old_version': 2019, 'new_version': 'all'},
    'win_sus': {'platform': 'Windows', 'old_version': 2016, 'new_version': 'all'},
}

def fix_platform_versions():
    """Fix platform versions in role meta files."""
    print("=== Fixing Platform Versions in Meta Files ===\n")
    
    fixed_count = 0
    error_count = 0
    
    for role_name, config in ROLES_TO_FIX.items():
        meta_file = Path(f"roles/{role_name}/meta/main.yml")
        
        if not meta_file.exists():
            print(f"⚠ Skipping {role_name}: meta file not found")
            error_count += 1
            continue
        
        # Create backup
        backup_file = meta_file.with_suffix('.yml.bak')
        print(f"Processing {role_name}...")
        print(f"  Creating backup: {backup_file}")
        
        try:
            # Read the file
            with open(meta_file, 'r') as f:
                content = f.read()
            
            # Create backup
            with open(backup_file, 'w') as f:
                f.write(content)
            
            # Parse YAML
            data = yaml.safe_load(content)
            
            # Find and update platform versions
            if 'galaxy_info' in data and 'platforms' in data['galaxy_info']:
                updated = False
                for platform in data['galaxy_info']['platforms']:
                    if platform.get('name') == config['platform']:
                        if 'versions' in platform:
                            old_version = config['old_version']
                            new_version = config['new_version']
                            
                            # Handle both string and numeric versions
                            if old_version in platform['versions']:
                                idx = platform['versions'].index(old_version)
                                platform['versions'][idx] = new_version
                                updated = True
                                print(f"  ✓ Updated {config['platform']} version: {old_version} → {new_version}")
                
                if updated:
                    # Write updated YAML
                    with open(meta_file, 'w') as f:
                        yaml.dump(data, f, default_flow_style=False, sort_keys=False)
                    fixed_count += 1
                    print(f"  ✓ Saved {meta_file}")
                else:
                    print(f"  ⚠ No matching version found to update")
                    error_count += 1
            else:
                print(f"  ⚠ No platforms found in galaxy_info")
                error_count += 1
        
        except Exception as e:
            print(f"  ✗ Error processing {role_name}: {e}")
            error_count += 1
        
        print()
    
    print("=== Summary ===")
    print(f"Roles fixed: {fixed_count}")
    print(f"Errors/Skipped: {error_count}")
    print(f"\nBackup files created with .bak extension")
    print("\nNext steps:")
    print("  1. Review changes: git diff roles/*/meta/main.yml")
    print("  2. Run ansible-lint to verify: ansible-lint roles/")
    print("  3. If satisfied, remove backups: find roles -name 'main.yml.bak' -delete")
    print("\n✓ Platform version fixes complete!")

if __name__ == '__main__':
    fix_platform_versions()
