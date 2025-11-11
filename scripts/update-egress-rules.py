#!/usr/bin/env python3
"""
Script to replace hardcoded egress rules with dynamic blocks in all Terraform modules.
This implements DRY principle by eliminating 80+ duplicate egress blocks.
"""

import re
import os
from pathlib import Path

# Egress pattern to find and replace
EGRESS_PATTERN = r'''  # outbound internet access
  egress \{
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = \["0\.0\.0\.0/0"\]
  \}

  egress \{
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    ipv6_cidr_blocks = \["::/0"\]
  \}'''

# Alternative pattern without comment
EGRESS_PATTERN_NO_COMMENT = r'''  egress \{
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = \["0\.0\.0\.0/0"\]
  \}

  egress \{
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    ipv6_cidr_blocks = \["::/0"\]
  \}'''

# Locals block to add if not present
LOCALS_BLOCK = '''locals {
  # Common egress rules - allow all outbound traffic
  common_egress_rules = [
    {
      description      = "Allow all outbound IPv4 traffic"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
    },
    {
      description      = "Allow all outbound IPv6 traffic"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = []
      ipv6_cidr_blocks = ["::/0"]
    }
  ]
}

'''

# Dynamic egress block replacement
DYNAMIC_EGRESS = '''  # Dynamic egress rules - eliminates code duplication
  dynamic "egress" {
    for_each = local.common_egress_rules
    content {
      description      = egress.value.description
      from_port        = egress.value.from_port
      to_port          = egress.value.to_port
      protocol         = egress.value.protocol
      cidr_blocks      = egress.value.cidr_blocks
      ipv6_cidr_blocks = egress.value.ipv6_cidr_blocks
    }
  }'''

def process_file(filepath):
    """Process a single Terraform file."""
    print(f"Processing {filepath}...")
    
    with open(filepath, 'r') as f:
        content = f.read()
    
    original_content = content
    
    # Check if file has egress rules to replace
    has_egress = re.search(EGRESS_PATTERN, content) or re.search(EGRESS_PATTERN_NO_COMMENT, content)
    
    if not has_egress:
        print(f"  No egress rules found in {filepath}")
        return False
    
    # Add locals block if not present
    if 'locals {' not in content:
        # Add locals block at the beginning of the file
        content = LOCALS_BLOCK + content
        print(f"  Added locals block")
    
    # Replace egress blocks with dynamic block
    content = re.sub(EGRESS_PATTERN, DYNAMIC_EGRESS, content)
    content = re.sub(EGRESS_PATTERN_NO_COMMENT, DYNAMIC_EGRESS, content)
    
    if content != original_content:
        with open(filepath, 'w') as f:
            f.write(content)
        print(f"  ✓ Updated {filepath}")
        return True
    else:
        print(f"  No changes needed for {filepath}")
        return False

def main():
    """Main function to process all modules."""
    base_dirs = ['microsoft', 'unix']
    updated_count = 0
    
    for base_dir in base_dirs:
        if not os.path.exists(base_dir):
            continue
            
        print(f"\nProcessing {base_dir} modules...")
        
        # Find all main.tf files in subdirectories
        for root, dirs, files in os.walk(base_dir):
            if 'main.tf' in files:
                filepath = os.path.join(root, 'main.tf')
                # Skip parent main.tf files
                if filepath in [f'{base_dir}/main.tf']:
                    continue
                if process_file(filepath):
                    updated_count += 1
    
    print(f"\n✓ Updated {updated_count} files")
    print("Egress rule consolidation complete!")

if __name__ == '__main__':
    main()
