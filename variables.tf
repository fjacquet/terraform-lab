variable "public_key" {
  description = "SSH public key for EC2 instance access"
  type        = string
  default     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC+sBJl4PYrY+DEjXFU8QUR2wGrZruh/PETMkr585aIv/F06K7vcpR012J9cjh3Ib14Kx5PAHhrm2r/jAnMPLaBZinJIDJGGuc/Tv/m/3P39Yl/QvfTZ/A2Cjy0g6Igmc4C3Kd6T0WBRqxWRxM3yRJRuq2Iv9UDCAasQ/UFZ4RAWiPWkrQVWsJvkkEXcJ/TciV0+DBodXTaQQ1Af8a8tHuzD9m5ALkdgpmjqwnrNwrJCKy4R7Kn1ZcDMn0ajrVux/ejXrPch8APzC4iS2dlGel+hbHHpeAszkiFZpNMZ6SOH2u6Qq5viPffMKoAM00m7MvEfFziRx/EDSFul1Wk78pC599Q1QtVGaDIvQZwyRRZoOCOqWc+PaBnUa43AcETEOQt+7BylIpxczvi0NcIemyeisXtxCrfTZk6rZHF3r/NeSKHEUxadTXvPZHjkS2l4hzqHwGCfpEOIKNpBXRWchcm4cnMuXh6/ZUTda5BsYGZjX74KfTxrBkOxz0+J6HPUws= fjacquet@mm-fj.ljf.home"

  validation {
    condition     = can(regex("^(ssh-rsa|ssh-ed25519|ecdsa-sha2-nistp256|ecdsa-sha2-nistp384|ecdsa-sha2-nistp521) ", var.public_key))
    error_message = "Public key must be a valid SSH public key starting with ssh-rsa, ssh-ed25519, or ecdsa-sha2-nistp*."
  }
}

variable "key_name" {
  description = "Desired name of AWS key pair"
  default     = "aws"
}

variable "dns_suffix" {
  description = "name of DNS zone"
  default     = "ez-lab.xyz"
}
variable "public_dns_id" {
  description = "ID of public DNS"
  default     = "Z09111591ZZVC86K0WQ2K"
}

variable "azs" {
  description = "List of AWS availability zones for resource distribution (1-3 zones)"
  type        = list(string)

  default = [
    "eu-west-1a",
    # "eu-west-1b",
    # "eu-west-1c",
  ]

  validation {
    condition     = length(var.azs) >= 1 && length(var.azs) <= 3
    error_message = "Must specify between 1 and 3 availability zones."
  }
}

# Region
variable "aws_region" {
  description = "AWS region for infrastructure deployment"
  type        = string
  default     = "eu-west-1"

  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]{1}$", var.aws_region))
    error_message = "AWS region must be a valid region identifier (e.g., eu-west-1, us-east-1)."
  }
}

variable "aws_disks_size" {
  // type = map(string)

  default = {
    nbu_backups = 500
    nbu_openv   = 50
  }
}

variable "access_key" {
  description = "AWS access key (prefer using IAM roles or AWS SSO instead)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "secret_key" {
  description = "AWS secret key (prefer using IAM roles or AWS SSO instead)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "admin_cidr_blocks" {
  description = "CIDR blocks allowed for administrative access (RDP, SSH, WinRM). Restricts access to specific IP ranges for security. Default allows access only from within the VPC (10.0.0.0/16). For lab environments, this provides a secure default while allowing flexibility."
  type        = list(string)
  default     = ["10.0.0.0/16"]

  validation {
    condition     = alltrue([for cidr in var.admin_cidr_blocks : can(cidrhost(cidr, 0))])
    error_message = "All admin_cidr_blocks must be valid CIDR notation (e.g., 10.0.0.0/16, 192.168.1.0/24)."
  }
}

variable "enable_public_admin_access" {
  description = "Allow administrative access (RDP, SSH, WinRM) from the internet (0.0.0.0/0). WARNING: This is a security risk and should only be enabled for development/testing environments. When false, access is restricted to admin_cidr_blocks. Default is false for security."
  type        = bool
  default     = false
}

variable "cidrbyte" {
  description = "Third octet values for subnet CIDR blocks (10.0.X.0/24)"
  type        = map(number)

  default = {
    "back1.eu-west-1"     = 51
    "back2.eu-west-1"     = 52
    "back3.eu-west-1"     = 53
    "backup1.eu-west-1"   = 41
    "backup2.eu-west-1"   = 42
    "backup3.eu-west-1"   = 43
    "exchange1.eu-west-1" = 31
    "exchange2.eu-west-1" = 32
    "exchange3.eu-west-1" = 33
    "gw1.eu-west-1"       = 101
    "gw2.eu-west-1"       = 102
    "gw3.eu-west-1"       = 103
    "mgmt1.eu-west-1"     = 11
    "mgmt2.eu-west-1"     = 12
    "mgmt3.eu-west-1"     = 13
    "sql1.eu-west-1"      = 61
    "sql2.eu-west-1"      = 62
    "sql3.eu-west-1"      = 63
    "vpc.eu-west-1"       = 0
    "web1.eu-west-1"      = 1
    "web2.eu-west-1"      = 2
    "web3.eu-west-1"      = 3
  }

  validation {
    condition     = alltrue([for v in values(var.cidrbyte) : v >= 0 && v <= 255])
    error_message = "CIDR byte values must be between 0 and 255."
  }
}

variable "aws_number" {
  description = "Number of instances to create for each service type (0-10)"
  type        = map(number)

  default = {
    "adfs"       = 0
    "bsd"        = 0
    "da"         = 0
    "dc"         = 0
    "dhcp"       = 0
    "exchange"   = 0
    "fs"         = 0
    "glpi"       = 0
    "guacamole"  = 1
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

  validation {
    condition     = alltrue([for v in values(var.aws_number) : v >= 0 && v <= 10])
    error_message = "Instance counts must be between 0 and 10."
  }
}
