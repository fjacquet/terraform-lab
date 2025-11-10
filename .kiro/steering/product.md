## Product Overview

terraform-lab is an automated lab environment provisioning system for AWS. It creates and configures complete infrastructure labs with Windows and Linux systems for testing, training, and development purposes.

The project automates deployment of enterprise Microsoft services (Active Directory, Exchange, SharePoint, SQL Server, PKI, etc.) and Unix/Linux services (Guacamole bastion, GLPI, Vault, NetBackup, Oracle) in AWS using Terraform for infrastructure provisioning and Ansible for configuration management.

Key capabilities:

- Automated AWS infrastructure deployment with VPC, subnets, security groups
- Pre-configured Windows domain environments with enterprise services
- Linux-based management and backup systems
- Bastion host access via Guacamole for secure remote access
- Integration with AWS Secrets Manager for credential management
- Support for backup solutions (NetBackup, Simpana/Commvault)
