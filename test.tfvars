# Test configuration for infrastructure validation
# This file contains minimal instance counts and secure settings for testing

# Security Settings - Restrict admin access to VPC only
admin_cidr_blocks          = ["10.0.0.0/16"]
enable_public_admin_access = false

# Instance counts for testing - matching services defined in locals.tf
aws_number = {
  # Windows Services
  "adds"       = 3 # Active Directory Domain Services (was "dc")
  "adfs"       = 3 # Active Directory Federation Services
  "dhcp"       = 3 # DHCP Server
  "da"         = 3 # DirectAccess
  "exchange"   = 3 # Exchange Server
  "fs"         = 3 # File Server
  "ipam"       = 3 # IP Address Management
  "mgmt"       = 3 # Management Server
  "nps"        = 3 # Network Policy Server
  "rdsh"       = 3 # Remote Desktop Session Host
  "sharepoint" = 3 # SharePoint Server
  "sql"        = 3 # SQL Server
  "simpana"    = 3 # Commvault Simpana
  "sofs"       = 3 # Scale-Out File Server
  "wac"        = 3 # Windows Admin Center
  "wds"        = 3 # Windows Deployment Services
  "wsus"       = 3 # Windows Server Update Services

  # Unix/Linux Services
  "guacamole" = 1 # Apache Guacamole (bastion host)
  "glpi"      = 3 # GLPI IT Asset Management
  "vault"     = 3 # HashiCorp Vault
  "nbu"       = 3 # Veritas NetBackup
  "oracle"    = 3 # Oracle Database
  "redis"     = 3 # Redis
  "bsd"       = 3 # FreeBSD (AMI not available in all regions)

  # Kubernetes/Container Services (defined but not yet fully implemented)
  "etcd"     = 0 # etcd cluster for Kubernetes
  "workers"  = 0 # Kubernetes worker nodes
  "longhorn" = 0 # Distributed block storage
  "rancher"  = 0 # Kubernetes management platform

  # Additional Backup Services (defined but not yet fully implemented)
  "opscenter" = 0 # DataStax OpsCenter
  "symv"      = 0 # Symantec/Veritas backup

  # PKI Services (require special handling via pki_services in locals.tf)
  "pki-crl"  = 0 # PKI CRL Distribution Point
  "pki-ica"  = 0 # PKI Issuing CA
  "pki-rca"  = 0 # PKI Root CA
  "pki-ndes" = 0 # PKI NDES (SCEP)
}

# Use single AZ for testing
azs = ["eu-west-1a"]

# Region configuration
aws_region = "eu-west-1"

# DNS configuration
dns_suffix    = "ez-lab.xyz"
public_dns_id = "Z07150253A0MNSTGYQG5P"

# Key configuration
key_name = "aws-test"
