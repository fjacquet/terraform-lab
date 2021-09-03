variable "public_key" {
  description = "openssh aws"
  default     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC+sBJl4PYrY+DEjXFU8QUR2wGrZruh/PETMkr585aIv/F06K7vcpR012J9cjh3Ib14Kx5PAHhrm2r/jAnMPLaBZinJIDJGGuc/Tv/m/3P39Yl/QvfTZ/A2Cjy0g6Igmc4C3Kd6T0WBRqxWRxM3yRJRuq2Iv9UDCAasQ/UFZ4RAWiPWkrQVWsJvkkEXcJ/TciV0+DBodXTaQQ1Af8a8tHuzD9m5ALkdgpmjqwnrNwrJCKy4R7Kn1ZcDMn0ajrVux/ejXrPch8APzC4iS2dlGel+hbHHpeAszkiFZpNMZ6SOH2u6Qq5viPffMKoAM00m7MvEfFziRx/EDSFul1Wk78pC599Q1QtVGaDIvQZwyRRZoOCOqWc+PaBnUa43AcETEOQt+7BylIpxczvi0NcIemyeisXtxCrfTZk6rZHF3r/NeSKHEUxadTXvPZHjkS2l4hzqHwGCfpEOIKNpBXRWchcm4cnMuXh6/ZUTda5BsYGZjX74KfTxrBkOxz0+J6HPUws= fjacquet@mm-fj.ljf.home"
}

variable "key_name" {
  description = "Desired name of AWS key pair"
  default     = "aws"
}

variable "dns_suffix" {
  description = "name of DNS zone"
  default     = "ez-lab.xyz"
}

variable "azs" {
  description = "AWS availability zone to launch servers."
  // type        = list(string)

  default = [
    "eu-west-1a",
    # "eu-west-1b",
    # "eu-west-1c",
  ]
}

# variable "azs" {
#   description = "AWS availability zone to launch servers."
#   // type        = list(string)

#   default = [
#     "eu-west-1a",

#   ]
# }

# Region
variable "aws_region" {
  // type    = string
  default = "eu-west-1"
}

variable "aws_disks_size" {
  // type = map(string)

  default = {
    nbu_backups = 500
    nbu_openv   = 50
  }
}

variable "access_key" {
  default = ""
}

variable "secret_key" {
  default = ""
}

variable "cidrbyte" {
  type = map(string)

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
}

variable "aws_number" {
  type = map(string)

  default = {
    "adfs"       = 0
    "bsd"        = 0
    "da"         = 0
    "dc"         = 1
    "dhcp"       = 0
    "exchange"   = 0
    "fs"         = 0
    "glpi"       = 0
    "guacamole"  = 0
    "ipam"       = 0
    "jumpbox"    = 1
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
    "pki-rca"    = 1
    "pki-ndes"   = 0
    "rdsh"       = 0
    "redis"      = 0
    "sharepoint" = 0
    "simpana"    = 0
    "sql"        = 0
    "sofs"       = 0
    "symv"       = 0
    "wac"        = 0
    "wds"        = 0
    "wsus"       = 0
  }
}

variable "aws_amis" {
  type = map(string)

  default = {
    "bsd"        = "ami-02b4e72b17337d6c1"
    "glpi"       = "ami-02b4e72b17337d6c1"
    "etcd"       = "ami-02b4e72b17337d6c1"
    "workers"    = "ami-02b4e72b17337d6c1"
    "rancher"    = "ami-02b4e72b17337d6c1"
    "longhorn"   = "ami-02b4e72b17337d6c1"
    "guacamole"  = "ami-0a8e758f5e873d1c1" # Debian
    "jumpbox"    = "ami-0acec5a529be6b35a"
    "lnx"        = "ami-02b4e72b17337d6c1"
    "nbu"        = "ami-02b4e72b17337d6c1"
    "oracle"     = "ami-02b4e72b17337d6c1"
    "redis"      = "ami-0ec23856b3bad62d"
    "sharepoint" = "ami-0acec5a529be6b35a"
    "sql"        = "ami-0b710fe222abdeb24"
    "win2019"    = "ami-0acec5a529be6b35a"
    "wsus"       = "ami-0acec5a529be6b35a"
  }
}



data "aws_ami" "debian" {
  most_recent = true
  filter {
    name   = "name"
    values = ["debian-11-amd64*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["679593333241"] # Canonical
}
data "aws_ami" "windows2019" {
  most_recent = true
  filter {
    name   = "name"
    values = ["Windows_Server-2019-English-Full-Base-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["801119661308"] # Canonical
}
data "aws_ami" "sql2019" {
  most_recent = true
  filter {
    name   = "name"
    values = ["Windows_Server-2019-English-Full-SQL_2019_Enterprise-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["801119661308"] # Canonical
}
data "aws_ami" "windows-2016" {
  most_recent = true
  filter {
    name   = "name"
    values = ["Windows_Server-2016-English-Full-Base-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["801119661308"] # Canonical
}
data "aws_ami" "sql-2016" {
  most_recent = true
  filter {
    name   = "name"
    values = ["Windows_Server-2016-English-Full-SQL_2017_Standard-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["801119661308"] # Canonical
}
data "aws_ami" "rhel-8" {
  most_recent = true
  filter {
    name   = "name"
    values = ["Windows_Server-2019-English-Full-Base-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["801119661308"] # Canonical
}
