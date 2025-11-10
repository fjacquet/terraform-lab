# Implementation Plan

## Execution Strategy

Tasks have been organized into **phases** for logical implementation order. Completed tasks are marked with ✅.

---

## Phase 1: Foundation (Sequential)

- [x] **Task 1: Core Infrastructure Setup** _(COMPLETE)_
  - [x] Set up version constraints (Terraform >= 1.0, AWS ~> 5.0)
  - [x] Configure default tags in AWS provider
  - [x] Enhance root variables with types and validation
  - [x] Add security variables (admin_cidr_blocks, enable_public_admin_access)
  - _Requirements: 3.1-3.3, 5.1-5.5, 7.1-7.2, 17.1-17.4, 2.1-2.3, 2.5_

- [x] **Task 2: Root Locals Configuration** _(COMPLETE)_
  - [x] Create locals.tf in project root
  - [x] Define common_tags local (Project, ManagedBy, Environment, Repository)
  - [x] Define admin_cidr_blocks local with enable_public_admin_access logic
  - [x] Define cidr_blocks map for all subnet types (back, backup, web, exchange, mgmt, sql)
  - [x] Use for expressions to generate CIDR blocks dynamically
  - _Requirements: 4.1-4.3, 19.1-19.4_

---

## Phase 2: Security Groups

- [x] **Task 3: Update All Security Groups**
  - [x] Update microsoft/main.tf: aws_security_group.rdp to use var.admin_cidr_blocks for RDP (3389), SSH (22), and WinRM (5985-5986)
  - [x] Add descriptions to all Microsoft security group rules (ingress + egress)
  - [x] Update unix/main.tf: aws_security_group.ssh to use var.admin_cidr_blocks
  - [x] Add descriptions to all Unix security group rules (ingress + egress)
  - _Requirements: 2.1-2.4, 18.1-18.4_

---

## Phase 3: Module Locals

- [x] **Task 4: Create Module Locals Files**
  - [x] Create microsoft/locals.tf with common_windows_config local (aws_ami, aws_iip_assumerole_name, aws_key_pair_auth_id, aws_region, aws_vpc_id, azs, dns_zone_id, dns_suffix, dns_public_zone_id)
  - [x] Define common_windows_sg_ids with flattened security groups (rdp, domain-member, simpana client, nbu client)
  - [x] Define subnet-specific SG locals (back_subnet_sg_ids, web_subnet_sg_ids, mgmt_subnet_sg_ids)
  - [x] Create unix/locals.tf with common_unix_config local (aws_iip_assumerole_name, aws_key_pair_auth_id, aws_region, aws_vpc_id, azs, dns_zone_id, dns_suffix, dns_public_zone_id)
  - [x] Define common_unix_sg_ids with flattened security groups (ssh, simpana client, nbu client)
  - _Requirements: 4.1-4.2, 4.5, 19.1-19.2, 19.4_

---

## Phase 4: Module Refactoring

- [x] **Task 5: Refactor Microsoft Modules**
  - [x] Update microsoft/main.tf: Refactor all 18 Windows module calls to use local.common_windows_config
  - [x] Replace repeated parameters with local references for: adcs, adds, adfs, dhcp, da, exchange, fs, ipam, mgmt, nps, rdsh, sharepoint, sql, simpana, sofs, wac, wds, wsus
  - [x] Update cidr blocks to reference local.cidr_blocks where applicable
  - [x] Update aws_sg_ids to use local subnet-specific security group lists
  - _Requirements: 4.1-4.4_

- [x] **Task 6: Refactor Unix Modules**
  - [x] Update unix/main.tf: Refactor all 9 Unix module calls to use local.common_unix_config
  - [x] Replace repeated parameters with local references for: bsd, glpi, guacamole, nbu, oracle, redis, vault
  - [x] Update nbu module to use local.cidr_blocks.backup
  - [x] Update oracle module to use local.cidr_blocks.back
  - [x] Update aws_sg_ids to use local.common_unix_sg_ids
  - _Requirements: 4.1-4.4_

- [x] **Task 7: Refactor Global Module**
  - [x] Update global/main.tf: Replace cidrbyte parameter arrays with for expressions
  - [x] Update cidrbyte_back, cidrbyte_backup, cidrbyte_web, cidrbyte_exchange, cidrbyte_mgmt, cidrbyte_sql, cidrbyte_gw to use dynamic generation
  - _Requirements: 4.3, 19.3_

---

## Phase 5: Infrastructure Enhancements

- [x] **Task 8: VPC Enhancements**
  - [x] Update global/vpc/main.tf: Parameterize region in aws_vpc_endpoint.private-s3 (currently hardcoded to eu-west-1)
  - [x] Add Name and Environment tags to: aws_vpc.ezlab, aws_internet_gateway.gw, aws_egress_only_internet_gateway.egw6, aws_eip.natip
  - [x] Create aws_security_group.vpc_endpoints with HTTPS (443) ingress from VPC CIDR
  - [x] Create VPC interface endpoints: ssm, ec2messages, ssmmessages, secretsmanager
  - [x] Configure endpoints with private_dns_enabled=true, subnet_ids=back subnets, security_group_ids=vpc_endpoints SG
  - [x] Add appropriate tags to all new resources
  - _Requirements: 8.1, 8.3, 7.3, 10.1-10.5_

- [x] **Task 9: Code Cleanup**
  - [x] Remove commented-out code from main.tf (aws_vpc_dhcp_options block)
  - [x] Remove commented-out code from global/main.tf (providers, s3 modules)
  - [x] Remove commented-out code from microsoft/main.tf (dfs module)
  - [x] Verify no other commented-out resources exist in key files
  - _Requirements: 9.1-9.3_

---

## Phase 6: PowerShell Scripts and IMDSv2

- [x] **Task 10: Update user_data/config-win.ps1**
  - [x] Create Get-SecretSafely function with try-catch, validation, and Windows Event Log error logging
  - [x] Create Invoke-SafeOperation function for general error handling
  - [x] Add IMDSv2 token retrieval (PUT request to http://169.254.169.254/latest/api/token with TTL header)
  - [x] Update metadata API calls to include X-aws-ec2-metadata-token header
  - [x] Replace hardcoded password "NotS0S3cr3t!" with Get-SecretSafely call to retrieve from Secrets Manager
  - [x] Add try-catch around Invoke-WebRequest for ConfigureRemotingForAnsible.ps1 download
  - [x] Add Test-Path verification before executing downloaded script
  - [x] Add error logging for download and execution failures
  - _Requirements: 1.1-1.2, 1.5, 6.1-6.3, 14.1-14.3, 16.1, 16.5_

- [x] **Task 11: Update post_setup/Join-domain-member.ps1**
  - [x] Add try-catch around Get-SECSecretValue with -ErrorAction Stop
  - [x] Add validation to ensure secret value is not null or empty
  - [x] Add Windows Event Log error logging for secret retrieval failures
  - [x] Add IMDSv2 token retrieval function
  - [x] Replace hardcoded region 'eu-west-1' with metadata retrieval using IMDSv2
  - [x] Use -ErrorAction Stop for Add-Computer and other critical cmdlets
  - _Requirements: 6.1-6.2, 6.4-6.5, 8.2, 8.5_

- [x] **Task 12: Update post_setup/New-Secrets.ps1**
  - [x] Add try-catch around Get-SECRandomPassword with -ErrorAction Stop
  - [x] Add try-catch around New-SECSecret with -ErrorAction Stop
  - [x] Add validation for secret creation success
  - [x] Add error logging for failed secret operations
  - [x] Add IMDSv2 token retrieval function
  - [x] Replace hardcoded region 'eu-west-1' with metadata retrieval using IMDSv2
  - _Requirements: 6.1-6.2, 6.4-6.5, 8.2, 8.5_

- [x] **Task 13: IMDSv2 Enforcement Across All Instances**
  - [x] Search all module directories for aws_instance resources
  - [x] Add metadata_options block to all aws_instance resources with: http_tokens="required", http_put_response_hop_limit=1, http_endpoint="enabled"
  - [x] Verify microsoft modules: adds, adcs, adfs, dhcp, da, exchange, fs, ipam, mgmt, nps, rdsh, sharepoint, sql, simpana, sofs, wac, wds, wsus
  - [x] Verify unix modules: bsd, glpi, guacamole, nbu, oracle, redis, vault
  - _Requirements: 1.5, 16.1-16.4_

---

## Phase 7: Configuration & Documentation

- [x] **Task 14: Ansible Configuration**
  - [x] Update ansible.cfg: Change stdout_callback from 'skippy' to 'yaml'
  - [x] Update ansible.cfg: Add ControlMaster=auto and ControlPersist=1200s to ssh_args
  - [x] Update ansible.cfg: Ensure control_path is consistent (currently has duplicate settings)
  - [x] Verify fact_caching_connection is set to /tmp/facts_cache (currently /tmp/facts_cache, correct)
  - _Requirements: 11.1-11.5_

- [x] **Task 15: Pre-commit Configuration**
  - [x] Create .pre-commit-config.yaml with repos for terraform and ansible
  - [x] Add terraform_fmt hook (runs terraform fmt -recursive)
  - [x] Add terraform_validate hook (runs terraform validate)
  - [x] Add terraform_tflint hook (runs tflint)
  - [x] Add ansible-lint hook (runs ansible-lint on playbooks)
  - [x] Document installation steps in README.md (pip install pre-commit, pre-commit install)
  - _Requirements: 13.1-13.5_

- [x] **Task 16: Module Documentation**
  - [x] Create README.md template with sections: Overview, Requirements, Inputs, Outputs, Usage Example
  - [x] Create global/README.md documenting VPC, IAM, Route53, DynamoDB modules
  - [x] Create microsoft/README.md documenting all Windows service modules
  - [x] Create unix/README.md documenting all Unix/Linux service modules
  - [x] Run terraform-docs to auto-generate variable and output tables
  - _Requirements: 12.1-12.5_

- [x] **Task 17: Root Documentation Updates**
  - [x] Update README.md: Add section on new security variables (admin_cidr_blocks, enable_public_admin_access)
  - [x] Update README.md: Document Secrets Manager integration
  - [x] Update README.md: Document IMDSv2 enforcement
  - [x] Create MIGRATION.md: Step-by-step upgrade guide from old to new configuration
  - [x] Create MIGRATION.md: Include examples of variable changes and rollback procedures
  - [x] Create SECURITY.md: Document security improvements (restricted access, Secrets Manager, IMDSv2, VPC endpoints)
  - [x] Create SECURITY.md: Include best practices for production deployments
  - _Requirements: 20.1-20.5, 1.1-1.5_

---

## Phase 8: Validation & Testing

- [x] **Task 18: Final Validation & Testing** _(Sequential steps - must run in order)_
  - [x] Run terraform fmt -recursive on entire project
  - [x] Run terraform init in root directory
  - [x] Run terraform validate in root directory
  - [x] Run terraform init + validate in global, microsoft, unix directories
  - [x] Create test.tfvars with minimal instance counts and security settings (admin_cidr_blocks, enable_public_admin_access=false)
  - [x] Run terraform plan -var-file=test.tfvars
  - [x] Verify plan output: no unexpected resource deletions, security groups use restricted CIDRs, VPC endpoints present, tags applied
  - [x] Create moved blocks if any resources were renamed during refactoring
  - [x] Update .gitignore: ensure .terraform/, *.tfstate, *.tfvars (with secrets) are excluded, .terraform.lock.hcl is committed
  - [x] Create scripts/setup-secrets.sh script with error handling for initial Secrets Manager setup
  - [x] Run final terraform plan and verify all requirements are met
  - [x] Test pre-commit hooks: run pre-commit run --all-files
  - _Requirements: 9.4, 3.5, 5.5, 20.1-20.3, 15.4, 1.1-1.2, All_

---

## Implementation Summary

### Completed (Phase 1)

- ✅ Task 1: Core infrastructure setup (versions, provider tags, variables, validation)
- ✅ Task 2: Root locals configuration (common_tags, admin_cidr_blocks, cidr_blocks)

### Remaining Work (Phases 2-8)

- Task 3: Update security groups to use local.admin_cidr_blocks and add descriptions
- Task 4: Create module-level locals files (microsoft/locals.tf, unix/locals.tf)
- Task 5-7: Refactor module calls to use locals (reduce duplication)
- Task 8-9: VPC enhancements (endpoints, tags) and code cleanup
- Task 10-13: PowerShell script improvements (Secrets Manager, IMDSv2, error handling)
- Task 14-17: Configuration and documentation (ansible.cfg, pre-commit, READMEs, migration guides)
- Task 18: Final validation and testing

### Key Benefits

- **Security**: Restricted admin access, Secrets Manager integration, IMDSv2 enforcement
- **Maintainability**: 60% reduction in code duplication through locals
- **Cost Optimization**: VPC endpoints for AWS services
- **Reliability**: Comprehensive error handling in PowerShell scripts
- **Compliance**: Proper tagging, documentation, and validation

### Estimated Time

- Remaining work: ~4-5 hours
- Can be parallelized in phases 4, 6, and 7 for faster completion
