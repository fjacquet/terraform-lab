# Test configuration for infrastructure validation
# This file contains minimal instance counts and secure settings for testing

# Security Settings - Restrict admin access to VPC only
admin_cidr_blocks          = ["10.0.0.0/16"]
enable_public_admin_access = false

# Minimal instance counts for testing
aws_number = {
  "adfs"       = 0
  "bsd"        = 0
  "da"         = 0
  "dc"         = 0 # Domain controller - set to 0 for minimal test
  "dhcp"       = 0
  "exchange"   = 0
  "fs"         = 0
  "glpi"       = 0
  "guacamole"  = 1 # Keep bastion host for access
  "ipam"       = 0
  "mgmt"       = 0
  "etcd"       = 0
  "workers"    = 0
  "longhorn"   = 0
  "rancher"    = 0
  "nbu"        = 0
  "nps"        = 0
  "opscenter"  = 0
  "oracle"     = 0
  "pki-crl"    = 0
  "pki-ica"    = 0
  "pki-rca"    = 0
  "pki-ndes"   = 0
  "rdsh"       = 0
  "redis"      = 0
  "sharepoint" = 0
  "simpana"    = 0
  "sql"        = 0
  "sofs"       = 0
  "symv"       = 0
  "vault"      = 0
  "wac"        = 0
  "wds"        = 0
  "wsus"       = 0
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
