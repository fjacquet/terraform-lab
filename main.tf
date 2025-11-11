# ============================================================================
# TERRAFORM-LAB ROOT MODULE (REFACTORED)
# Modern architecture using for_each pattern
# 3 levels → 2 levels: root → modules/service
# ============================================================================

# ============================================================================
# GLOBAL INFRASTRUCTURE
# ============================================================================

module "global" {
  source = "./global"

  access_key    = var.access_key
  aws_number    = var.aws_number
  aws_region    = var.aws_region
  azs           = var.azs
  cidrbyte      = var.cidrbyte
  dns_suffix    = var.dns_suffix
  public_dns_id = var.public_dns_id
  key_name      = var.key_name
  public_key    = var.public_key
  secret_key    = var.secret_key
}

# ============================================================================
# COMMON SECURITY GROUPS
# ============================================================================

# Windows RDP/SSH/WinRM access
resource "aws_security_group" "rdp" {
  name        = "tf_ezlab_rdp"
  description = "Security group for Windows administrative access (RDP, SSH, WinRM)"
  vpc_id      = module.global.aws_vpc_id

  ingress {
    description = "Allow RDP from admin CIDR blocks"
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = local.admin_cidr_blocks
  }

  ingress {
    description = "Allow SSH from admin CIDR blocks"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = local.admin_cidr_blocks
  }

  ingress {
    description = "Allow WinRM (HTTP and HTTPS) from admin CIDR blocks"
    from_port   = 5985
    to_port     = 5986
    protocol    = "tcp"
    cidr_blocks = local.admin_cidr_blocks
  }

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
  }
}

# Unix/Linux SSH access
resource "aws_security_group" "ssh" {
  name        = "tf_ezlab_lssh"
  description = "Security group for Unix/Linux administrative access (SSH)"
  vpc_id      = module.global.aws_vpc_id

  ingress {
    description = "Allow SSH from admin CIDR blocks"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = local.admin_cidr_blocks
  }

  ingress {
    description = "Allow Cockpit web console from VPC"
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

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
  }
}

# Active Directory domain member traffic
resource "aws_security_group" "domain_member" {
  name        = "tf_ezlab_domain_member"
  description = "Security group for Active Directory domain member traffic"
  vpc_id      = module.global.aws_vpc_id

  # ICMP ping
  ingress {
    description = "Allow ICMP ping from domain members"
    from_port   = 8
    to_port     = 8
    protocol    = "icmp"
    self        = true
  }

  # DNS (TCP and UDP)
  ingress {
    description = "Allow DNS TCP from domain members"
    from_port   = 53
    to_port     = 53
    protocol    = "tcp"
    self        = true
  }
  ingress {
    description = "Allow DNS UDP from domain members"
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    self        = true
  }

  # Kerberos (TCP and UDP)
  ingress {
    description = "Allow Kerberos TCP from domain members"
    from_port   = 88
    to_port     = 88
    protocol    = "tcp"
    self        = true
  }
  ingress {
    description = "Allow Kerberos UDP from domain members"
    from_port   = 88
    to_port     = 88
    protocol    = "udp"
    self        = true
  }

  # NTP
  ingress {
    description = "Allow NTP from domain members"
    from_port   = 123
    to_port     = 123
    protocol    = "udp"
    self        = true
  }

  # RPC endpoint mapper
  ingress {
    description = "Allow RPC endpoint mapper from domain members"
    from_port   = 135
    to_port     = 135
    protocol    = "tcp"
    self        = true
  }

  # LDAP (TCP and UDP)
  ingress {
    description = "Allow LDAP TCP from domain members"
    from_port   = 389
    to_port     = 389
    protocol    = "tcp"
    self        = true
  }
  ingress {
    description = "Allow LDAP UDP from domain members"
    from_port   = 389
    to_port     = 389
    protocol    = "udp"
    self        = true
  }

  # SMB/CIFS (TCP and UDP)
  ingress {
    description = "Allow SMB TCP from domain members"
    from_port   = 445
    to_port     = 445
    protocol    = "tcp"
    self        = true
  }
  ingress {
    description = "Allow SMB UDP from domain members"
    from_port   = 445
    to_port     = 445
    protocol    = "udp"
    self        = true
  }

  # LDAPS
  ingress {
    description = "Allow LDAPS TCP from domain members"
    from_port   = 636
    to_port     = 636
    protocol    = "tcp"
    self        = true
  }
  ingress {
    description = "Allow LDAPS UDP from domain members"
    from_port   = 636
    to_port     = 636
    protocol    = "udp"
    self        = true
  }

  # Kerberos password change
  ingress {
    description = "Allow Kerberos password change from domain members"
    from_port   = 749
    to_port     = 749
    protocol    = "udp"
    self        = true
  }

  # LDAP Global Catalog
  ingress {
    description = "Allow LDAP Global Catalog from domain members"
    from_port   = 3268
    to_port     = 3269
    protocol    = "tcp"
    self        = true
  }

  # WinRM
  ingress {
    description = "Allow WinRM from domain members"
    from_port   = 5985
    to_port     = 5986
    protocol    = "tcp"
    self        = true
  }

  # Dynamic RPC ports
  ingress {
    description = "Allow dynamic RPC ports from domain members"
    from_port   = 49152
    to_port     = 65535
    protocol    = "tcp"
    self        = true
  }

  # FusionInventory agent
  ingress {
    description = "Allow FusionInventory agent from VPC"
    from_port   = 62354
    to_port     = 62354
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }
  ingress {
    description      = "Allow FusionInventory agent from IPv6"
    from_port        = 62354
    to_port          = 62354
    protocol         = "tcp"
    ipv6_cidr_blocks = ["::/0"]
  }

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
  }
}

# Simpana client security group (placeholder - will be created by simpana service)
# This is referenced by other services, so we need to handle it specially
locals {
  simpana_client_sg_id = try(module.services["simpana"].security_group_id, "")
}

# ============================================================================
# AMI DATA SOURCES
# ============================================================================

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
  owners = ["801119661308"]
}

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
  owners = ["801119661308"]
}

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
  owners = ["136693071363"]
}

data "aws_ami" "rhel9" {
  count       = (var.aws_number["nbu"] + var.aws_number["oracle"]) > 0 ? 1 : 0
  most_recent = true
  filter {
    name   = "name"
    values = ["RHEL-9.*_HVM-*-x86_64-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["309956199498"]
}

data "aws_ami" "bsd" {
  count       = var.aws_number["bsd"] > 0 ? 1 : 0
  most_recent = true
  filter {
    name   = "name"
    values = ["FreeBSD 13.*-RELEASE-amd64*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["118940168514"]
}

# ============================================================================
# AMI ID MAP
# ============================================================================

locals {
  ami_ids = {
    windows2022 = data.aws_ami.windows2022.id
    sql2019     = data.aws_ami.sql2019.id
    debian      = data.aws_ami.debian.id
    rhel9       = (var.aws_number["nbu"] + var.aws_number["oracle"]) > 0 ? data.aws_ami.rhel9[0].id : ""
    bsd         = var.aws_number["bsd"] > 0 ? data.aws_ami.bsd[0].id : ""
  }
}

# ============================================================================
# UNIFIED SERVICE DEPLOYMENT
# Single for_each loop for ALL services (Windows + Unix)
# ============================================================================

module "services" {
  for_each = { for k, v in local.all_services : k => v if lookup(var.aws_number, k, 0) > 0 }

  source = "./modules/service"

  service_name   = each.key
  instance_count = var.aws_number[each.key]
  config         = each.value

  # Common configuration passed once for all services
  ami_ids                  = local.ami_ids
  common_metadata_options  = local.common_instance_metadata_options
  common_root_block_device = local.common_instance_root_block_device

  vpc_id = module.global.aws_vpc_id

  subnets = {
    back     = module.global.aws_subnet_back_id
    web      = module.global.aws_subnet_web_id
    mgmt     = module.global.aws_subnet_mgmt_id
    exchange = module.global.aws_subnet_exchange_id
    backup   = module.global.aws_subnet_backup_id
  }

  cidr_blocks = local.cidr_blocks

  azs                  = var.azs
  iam_instance_profile = module.global.aws_iip_assumerole
  key_pair_id          = aws_key_pair.auth.id

  dns_zone_id        = module.global.dns_zone_id
  dns_public_zone_id = var.public_dns_id
  dns_suffix         = var.dns_suffix

  security_groups = {
    rdp            = aws_security_group.rdp.id
    ssh            = aws_security_group.ssh.id
    domain_member  = aws_security_group.domain_member.id
    simpana_client = local.simpana_client_sg_id
  }

  # NBU client security groups (for services that need them)
  nbu_client_sg_ids = try([module.services["nbu"].security_group_id], [])
}

# ============================================================================
# SSH KEY PAIR
# ============================================================================

# Note: aws_key_pair.auth is defined in backend.tf
