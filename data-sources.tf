# ============================================================================
# DATA SOURCES
# AMI lookups for different operating systems
# ============================================================================

# Windows Server 2022
data "aws_ami" "windows2022" {
  most_recent = true

  filter {
    name   = "name"
    values = ["Windows_Server-2022-English-Full-Base-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["801119661308"] # Amazon
}

# SQL Server 2019 on Windows Server 2019
data "aws_ami" "sql2019" {
  most_recent = true

  filter {
    name   = "name"
    values = ["Windows_Server-2019-English-Full-SQL_2019_Standard-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["801119661308"] # Amazon
}

# Debian 12
data "aws_ami" "debian" {
  most_recent = true

  filter {
    name   = "name"
    values = ["debian-12-amd64-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["136693071363"] # Debian
}

# RHEL 9 (conditional - only if nbu or oracle services are enabled)
data "aws_ami" "rhel9" {
  count       = (lookup(var.aws_number, "nbu", 0) + lookup(var.aws_number, "oracle", 0)) > 0 ? 1 : 0
  most_recent = true

  filter {
    name   = "name"
    values = ["RHEL-9.*_HVM-*-x86_64-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["309956199498"] # Red Hat
}

# FreeBSD 15 (conditional - only if bsd service is enabled)
data "aws_ami" "bsd" {
  count       = lookup(var.aws_number, "bsd", 0) > 0 ? 1 : 0
  most_recent = true

  filter {
    name   = "name"
    values = ["FreeBSD*15.0-CURRENT-*ZFS"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["782442783595"] # FreeBSD

  # Note: FreeBSD AMIs may not be available in all regions
  # If deployment fails, set bsd = 0 in your tfvars file
}
