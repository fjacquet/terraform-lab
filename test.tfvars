# Test configuration for infrastructure validation
# This file contains minimal instance counts and secure settings for testing

# Security Settings - Restrict admin access to VPC only
admin_cidr_blocks          = ["10.0.0.0/16"]
enable_public_admin_access = false

# Minimal instance counts for testing
aws_number = {
  "adfs"       = 3
  "bsd"        = 3
  "da"         = 3
  "dc"         = 3 # Domain controller - set to 0 for minimal test
  "dhcp"       = 3
  "exchange"   = 3
  "fs"         = 3
  "glpi"       = 3
  "guacamole"  = 1 # Keep bastion host for access
  "ipam"       = 3
  "mgmt"       = 3
  "etcd"       = 3
  "workers"    = 3
  "longhorn"   = 3
  "rancher"    = 3
  "nbu"        = 3
  "nps"        = 3
  "opscenter"  = 3
  "oracle"     = 3
  "pki-crl"    = 3
  "pki-ica"    = 3
  "pki-rca"    = 3
  "pki-ndes"   = 3
  "rdsh"       = 3
  "redis"      = 3
  "sharepoint" = 3
  "simpana"    = 3
  "sql"        = 3
  "sofs"       = 3
  "symv"       = 3
  "vault"      = 3
  "wac"        = 3
  "wds"        = 3
  "wsus"       = 3
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
