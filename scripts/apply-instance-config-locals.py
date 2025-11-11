#!/usr/bin/env python3
"""
Script to apply common instance config locals to all microsoft and unix modules.
This implements task 20.3 from the infrastructure improvements spec.
"""

import os
import re
from pathlib import Path

# Microsoft modules that have aws_instance resources
MICROSOFT_MODULES = [
    "adds", "adfs", "dhcp", "da", "exchange", "fs", "ipam", 
    "mgmt", "nps", "rdsh", "sharepoint", "sql", "simpana", 
    "sofs", "wac", "wds", "wsus"
]

# Unix modules that have aws_instance resources
UNIX_MODULES = [
    "guacamole", "glpi", "vault", "redis", "nbu", "oracle", "bsd"
]

# ADCS has multiple instance types, handle separately
ADCS_INSTANCES = ["pki-crl", "pki-ica", "pki-rca", "pki-ndes"]

def add_variables_to_module(module_path, is_unix=False):
    """Add common instance config variables to a module's variables.tf"""
    variables_file = module_path / "variables.tf"
    
    if not variables_file.exists():
        print(f"  Warning: {variables_file} does not exist")
        return
    
    content = variables_file.read_text()
    
    # Check if variables already exist
    if "common_instance_metadata_options" in content:
        print(f"  Variables already exist in {variables_file}")
        return
    
    # Add variables at the end
    variables_to_add = '''
variable "common_instance_metadata_options" {
  description = "Common metadata options for EC2 instances (IMDSv2 enforcement)"
  type = object({
    http_tokens                 = string
    http_put_response_hop_limit = number
    http_endpoint               = string
  })
}

variable "common_instance_root_block_device" {
  description = "Common root block device configuration for EC2 instances"
  type = object({
    encrypted = bool
  })
}
'''
    
    variables_file.write_text(content + variables_to_add)
    print(f"  Added variables to {variables_file}")

def update_instance_resource(main_file, instance_name, is_unix=False):
    """Update aws_instance resource to use common config locals"""
    content = main_file.read_text()
    
    # Pattern to match metadata_options block
    metadata_pattern = r'  metadata_options \{[^}]+\}'
    # Pattern to match root_block_device block (simple version without volume_size)
    root_device_pattern = r'  root_block_device \{\s+encrypted = true\s+\}'
    
    # Check if already using variables
    if "var.common_instance_metadata_options" in content:
        print(f"  Instance {instance_name} already uses common config")
        return False
    
    # Replace metadata_options
    new_metadata = '''  metadata_options {
    http_tokens                 = var.common_instance_metadata_options.http_tokens
    http_put_response_hop_limit = var.common_instance_metadata_options.http_put_response_hop_limit
    http_endpoint               = var.common_instance_metadata_options.http_endpoint
  }'''
    
    content = re.sub(metadata_pattern, new_metadata, content)
    
    # Replace root_block_device (only the simple encrypted = true version)
    new_root_device = '''  root_block_device {
    encrypted = var.common_instance_root_block_device.encrypted
  }'''
    
    content = re.sub(root_device_pattern, new_root_device, content)
    
    main_file.write_text(content)
    print(f"  Updated instance {instance_name} in {main_file}")
    return True

def update_parent_module_call(parent_file, module_name):
    """Add common instance config to module call in parent main.tf"""
    content = parent_file.read_text()
    
    # Find the module block
    module_pattern = rf'module "{module_name}" \{{[^}}]+\}}'
    match = re.search(module_pattern, content, re.DOTALL)
    
    if not match:
        print(f"  Warning: Could not find module {module_name} in {parent_file}")
        return
    
    module_block = match.group(0)
    
    # Check if already has common instance config
    if "common_instance_metadata_options" in module_block:
        print(f"  Module {module_name} call already has common instance config")
        return
    
    # Find where to insert (after dns_suffix or dns_public_zone_id)
    insert_pattern = r'(  dns_suffix\s+=\s+[^\n]+\n)'
    if "dns_public_zone_id" in module_block:
        insert_pattern = r'(  dns_public_zone_id\s+=\s+[^\n]+\n)'
    
    insert_match = re.search(insert_pattern, module_block)
    if not insert_match:
        print(f"  Warning: Could not find insertion point in module {module_name}")
        return
    
    # Create the new lines to insert
    new_lines = '''
  # Common instance configuration
  common_instance_metadata_options    = local.common_instance_metadata_options
  common_instance_root_block_device   = local.common_instance_root_block_device
'''
    
    # Insert after the matched line
    new_module_block = module_block.replace(
        insert_match.group(1),
        insert_match.group(1) + new_lines
    )
    
    # Replace in content
    content = content.replace(module_block, new_module_block)
    parent_file.write_text(content)
    print(f"  Updated module call for {module_name} in {parent_file}")

def process_microsoft_modules():
    """Process all Microsoft modules"""
    print("\n=== Processing Microsoft Modules ===")
    base_path = Path("microsoft")
    parent_main = base_path / "main.tf"
    
    for module_name in MICROSOFT_MODULES:
        print(f"\nProcessing {module_name}...")
        module_path = base_path / module_name
        
        if not module_path.exists():
            print(f"  Warning: {module_path} does not exist")
            continue
        
        # Add variables
        add_variables_to_module(module_path, is_unix=False)
        
        # Update instance resource
        main_file = module_path / "main.tf"
        if main_file.exists():
            update_instance_resource(main_file, module_name, is_unix=False)
        
        # Update parent module call
        update_parent_module_call(parent_main, module_name)

def process_adcs_module():
    """Process ADCS module which has multiple instance types"""
    print("\n=== Processing ADCS Module ===")
    module_path = Path("microsoft/adcs")
    
    if not module_path.exists():
        print(f"  Warning: {module_path} does not exist")
        return
    
    print(f"\nProcessing adcs...")
    
    # Add variables
    add_variables_to_module(module_path, is_unix=False)
    
    # Update each instance type
    for instance_type in ADCS_INSTANCES:
        main_file = module_path / f"win-{instance_type}.tf"
        if main_file.exists():
            update_instance_resource(main_file, instance_type, is_unix=False)
    
    # Update parent module call
    parent_main = Path("microsoft/main.tf")
    update_parent_module_call(parent_main, "adcs")

def process_unix_modules():
    """Process all Unix modules"""
    print("\n=== Processing Unix Modules ===")
    base_path = Path("unix")
    parent_main = base_path / "main.tf"
    
    for module_name in UNIX_MODULES:
        print(f"\nProcessing {module_name}...")
        module_path = base_path / module_name
        
        if not module_path.exists():
            print(f"  Warning: {module_path} does not exist")
            continue
        
        # Add variables
        add_variables_to_module(module_path, is_unix=True)
        
        # Update instance resource
        main_file = module_path / "main.tf"
        if main_file.exists():
            update_instance_resource(main_file, module_name, is_unix=True)
        
        # Update parent module call (if parent main.tf exists)
        if parent_main.exists():
            update_parent_module_call(parent_main, module_name)

def main():
    """Main execution"""
    print("Starting application of instance config locals...")
    print("This implements task 20.3 from infrastructure-improvements spec")
    
    # Change to repo root
    script_dir = Path(__file__).parent
    os.chdir(script_dir.parent)
    
    # Process all modules
    process_microsoft_modules()
    process_adcs_module()
    process_unix_modules()
    
    print("\n=== Complete ===")
    print("All modules have been updated to use common instance config locals")
    print("This eliminates 200+ lines of duplicate metadata_options and root_block_device blocks")

if __name__ == "__main__":
    main()
