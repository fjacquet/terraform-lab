module "adcs" {
  source = "./adcs"

  # Common Windows configuration (only parameters this module accepts)
  aws_ami                 = local.common_windows_config.aws_ami
  aws_iip_assumerole_name = local.common_windows_config.aws_iip_assumerole_name
  aws_key_pair_auth_id    = local.common_windows_config.aws_key_pair_auth_id
  aws_vpc_id              = local.common_windows_config.aws_vpc_id
  azs                     = local.common_windows_config.azs
  dns_zone_id             = local.common_windows_config.dns_zone_id
  dns_suffix              = local.common_windows_config.dns_suffix

  # Common instance configuration
  common_instance_metadata_options    = local.common_instance_metadata_options
  common_instance_root_block_device   = local.common_instance_root_block_device

  # Service-specific configuration
  aws_number_pki-crl  = var.aws_number["pki-crl"]
  aws_number_pki-ica  = var.aws_number["pki-ica"]
  aws_number_pki-rca  = var.aws_number["pki-rca"]
  aws_number_pki-ndes = var.aws_number["pki-ndes"]
  aws_subnet_id       = var.aws_subnet_back_id

  # Use computed CIDR blocks from root locals
  cidr = local.cidr_blocks.back

  # Security groups with service-specific additions
  aws_sg_ids = flatten([
    local.back_subnet_sg_ids,
    module.adcs.aws_sg_pki-crl_ids,
    module.adcs.aws_sg_pki-ica_ids,
    module.adcs.aws_sg_pki-rca_ids,
  ])
}

module "adds" {
  source = "./adds"

  # Common Windows configuration
  aws_ami                 = local.common_windows_config.aws_ami
  aws_iip_assumerole_name = local.common_windows_config.aws_iip_assumerole_name
  aws_key_pair_auth_id    = local.common_windows_config.aws_key_pair_auth_id
  aws_region              = local.common_windows_config.aws_region
  aws_vpc_id              = local.common_windows_config.aws_vpc_id
  azs                     = local.common_windows_config.azs
  dns_zone_id             = local.common_windows_config.dns_zone_id
  dns_suffix              = local.common_windows_config.dns_suffix

  # Common instance configuration
  common_instance_metadata_options    = local.common_instance_metadata_options
  common_instance_root_block_device   = local.common_instance_root_block_device

  # Service-specific configuration
  aws_number    = var.aws_number["dc"]
  aws_subnet_id = var.aws_subnet_back_id

  # Use computed CIDR blocks from root locals
  cidr = local.cidr_blocks.back

  # Security groups with service-specific additions
  aws_sg_ids = flatten([
    local.back_subnet_sg_ids,
    module.adds.aws_sg_dc_id,
  ])

  aws_sg_domain_member = aws_security_group.domain-member.id
}

module "adfs" {
  source = "./adfs"

  # Common Windows configuration
  aws_ami                 = local.common_windows_config.aws_ami
  aws_iip_assumerole_name = local.common_windows_config.aws_iip_assumerole_name
  aws_key_pair_auth_id    = local.common_windows_config.aws_key_pair_auth_id
  aws_region              = local.common_windows_config.aws_region
  aws_vpc_id              = local.common_windows_config.aws_vpc_id
  azs                     = local.common_windows_config.azs
  dns_zone_id             = local.common_windows_config.dns_zone_id
  dns_suffix              = local.common_windows_config.dns_suffix

  # Common instance configuration
  common_instance_metadata_options    = local.common_instance_metadata_options
  common_instance_root_block_device   = local.common_instance_root_block_device

  # Service-specific configuration
  aws_number    = var.aws_number["adfs"]
  aws_subnet_id = var.aws_subnet_web_id

  # Use computed CIDR blocks from root locals
  cidr = local.cidr_blocks.web

  # Security groups with service-specific additions
  aws_sg_ids = flatten([
    local.web_subnet_sg_ids,
    module.adds.aws_sg_dc_id,
  ])
}

module "dhcp" {
  source = "./dhcp"

  # Common Windows configuration
  aws_ami                 = local.common_windows_config.aws_ami
  aws_iip_assumerole_name = local.common_windows_config.aws_iip_assumerole_name
  aws_key_pair_auth_id    = local.common_windows_config.aws_key_pair_auth_id
  aws_region              = local.common_windows_config.aws_region
  aws_vpc_id              = local.common_windows_config.aws_vpc_id
  azs                     = local.common_windows_config.azs
  dns_zone_id             = local.common_windows_config.dns_zone_id
  dns_suffix              = local.common_windows_config.dns_suffix

  # Common instance configuration
  common_instance_metadata_options    = local.common_instance_metadata_options
  common_instance_root_block_device   = local.common_instance_root_block_device

  # Service-specific configuration
  aws_number    = var.aws_number["dhcp"]
  aws_subnet_id = var.aws_subnet_back_id

  # Use computed CIDR blocks from root locals
  cidr = local.cidr_blocks.back

  # Security groups with service-specific additions
  aws_sg_ids = flatten([
    local.back_subnet_sg_ids,
    module.dhcp.aws_sg_dhcp_id,
  ])
}

module "da" {
  source = "./da"

  # Common Windows configuration
  aws_ami                 = local.common_windows_config.aws_ami
  aws_iip_assumerole_name = local.common_windows_config.aws_iip_assumerole_name
  aws_key_pair_auth_id    = local.common_windows_config.aws_key_pair_auth_id
  aws_region              = local.common_windows_config.aws_region
  aws_vpc_id              = local.common_windows_config.aws_vpc_id
  azs                     = local.common_windows_config.azs
  dns_zone_id             = local.common_windows_config.dns_zone_id
  dns_suffix              = local.common_windows_config.dns_suffix

  # Common instance configuration
  common_instance_metadata_options    = local.common_instance_metadata_options
  common_instance_root_block_device   = local.common_instance_root_block_device

  # Service-specific configuration
  aws_number    = var.aws_number["da"]
  aws_subnet_id = var.aws_subnet_mgmt_id

  # Use computed CIDR blocks from root locals (note: da uses web CIDR)
  cidr = local.cidr_blocks.web

  # Security groups with service-specific additions
  aws_sg_ids = flatten([
    local.mgmt_subnet_sg_ids,
    module.da.aws_sg_da_id,
  ])
}

module "exchange" {
  source = "./exchange"

  # Common Windows configuration
  aws_ami                 = local.common_windows_config.aws_ami
  aws_iip_assumerole_name = local.common_windows_config.aws_iip_assumerole_name
  aws_key_pair_auth_id    = local.common_windows_config.aws_key_pair_auth_id
  aws_region              = local.common_windows_config.aws_region
  aws_vpc_id              = local.common_windows_config.aws_vpc_id
  azs                     = local.common_windows_config.azs
  dns_zone_id             = local.common_windows_config.dns_zone_id
  dns_suffix              = local.common_windows_config.dns_suffix

  # Common instance configuration
  common_instance_metadata_options    = local.common_instance_metadata_options
  common_instance_root_block_device   = local.common_instance_root_block_device

  # Service-specific configuration
  aws_number    = var.aws_number["exchange"]
  aws_subnet_id = var.aws_subnet_exchange_id

  # Use computed CIDR blocks from root locals
  cidr = local.cidr_blocks.exchange

  # Security groups with service-specific additions
  aws_sg_ids = flatten([
    local.common_windows_sg_ids,
    module.exchange.aws_sg_exchange_id,
  ])
}

module "fs" {
  source = "./fs"

  # Common Windows configuration
  aws_ami                 = local.common_windows_config.aws_ami
  aws_iip_assumerole_name = local.common_windows_config.aws_iip_assumerole_name
  aws_key_pair_auth_id    = local.common_windows_config.aws_key_pair_auth_id
  aws_region              = local.common_windows_config.aws_region
  aws_vpc_id              = local.common_windows_config.aws_vpc_id
  azs                     = local.common_windows_config.azs
  dns_zone_id             = local.common_windows_config.dns_zone_id
  dns_suffix              = local.common_windows_config.dns_suffix

  # Common instance configuration
  common_instance_metadata_options    = local.common_instance_metadata_options
  common_instance_root_block_device   = local.common_instance_root_block_device

  # Service-specific configuration
  aws_number    = var.aws_number["fs"]
  aws_subnet_id = var.aws_subnet_back_id

  # Use computed CIDR blocks from root locals
  cidr = local.cidr_blocks.back

  # Security groups with service-specific additions
  aws_sg_ids = flatten([
    local.back_subnet_sg_ids,
    module.fs.aws_sg_fs_id,
  ])

  aws_sg_domain_members = aws_security_group.domain-member.id
}

module "ipam" {
  source = "./ipam/"

  # Common Windows configuration
  aws_ami                 = local.common_windows_config.aws_ami
  aws_iip_assumerole_name = local.common_windows_config.aws_iip_assumerole_name
  aws_key_pair_auth_id    = local.common_windows_config.aws_key_pair_auth_id
  aws_region              = local.common_windows_config.aws_region
  aws_vpc_id              = local.common_windows_config.aws_vpc_id
  azs                     = local.common_windows_config.azs
  dns_zone_id             = local.common_windows_config.dns_zone_id
  dns_suffix              = local.common_windows_config.dns_suffix

  # Common instance configuration
  common_instance_metadata_options    = local.common_instance_metadata_options
  common_instance_root_block_device   = local.common_instance_root_block_device

  # Service-specific configuration
  aws_number    = var.aws_number["ipam"]
  aws_subnet_id = var.aws_subnet_back_id

  # Use computed CIDR blocks from root locals
  cidr = local.cidr_blocks.back

  # Security groups with service-specific additions
  aws_sg_ids = flatten([
    local.back_subnet_sg_ids,
    module.ipam.aws_sg_ipam_id,
  ])
}

module "mgmt" {
  source = "./mgmt"

  # Common Windows configuration
  aws_ami                 = local.common_windows_config.aws_ami
  aws_iip_assumerole_name = local.common_windows_config.aws_iip_assumerole_name
  aws_key_pair_auth_id    = local.common_windows_config.aws_key_pair_auth_id
  aws_region              = local.common_windows_config.aws_region
  aws_vpc_id              = local.common_windows_config.aws_vpc_id
  azs                     = local.common_windows_config.azs
  dns_zone_id             = local.common_windows_config.dns_zone_id
  dns_public_zone_id      = local.common_windows_config.dns_public_zone_id

  # Common instance configuration
  common_instance_metadata_options    = local.common_instance_metadata_options
  common_instance_root_block_device   = local.common_instance_root_block_device
  dns_suffix              = local.common_windows_config.dns_suffix

  # Service-specific configuration
  aws_number    = var.aws_number["mgmt"]
  aws_subnet_id = var.aws_subnet_mgmt_id

  # Security groups (mgmt doesn't have cidr parameter)
  aws_sg_ids = local.mgmt_subnet_sg_ids
}

module "nps" {
  source = "./nps"

  # Common Windows configuration
  aws_ami                 = local.common_windows_config.aws_ami
  aws_iip_assumerole_name = local.common_windows_config.aws_iip_assumerole_name
  aws_key_pair_auth_id    = local.common_windows_config.aws_key_pair_auth_id
  aws_region              = local.common_windows_config.aws_region
  aws_vpc_id              = local.common_windows_config.aws_vpc_id
  azs                     = local.common_windows_config.azs
  dns_zone_id             = local.common_windows_config.dns_zone_id
  dns_suffix              = local.common_windows_config.dns_suffix

  # Common instance configuration
  common_instance_metadata_options    = local.common_instance_metadata_options
  common_instance_root_block_device   = local.common_instance_root_block_device

  # Service-specific configuration
  aws_number    = var.aws_number["nps"]
  aws_subnet_id = var.aws_subnet_back_id

  # Use computed CIDR blocks from root locals
  cidr = local.cidr_blocks.back

  # Security groups with service-specific additions
  aws_sg_ids = flatten([
    local.back_subnet_sg_ids,
    module.nps.aws_sg_nps_id,
  ])
}

module "rdsh" {
  source = "./rdsh"

  # Common Windows configuration
  aws_ami                 = local.common_windows_config.aws_ami
  aws_iip_assumerole_name = local.common_windows_config.aws_iip_assumerole_name
  aws_key_pair_auth_id    = local.common_windows_config.aws_key_pair_auth_id
  aws_region              = local.common_windows_config.aws_region
  aws_vpc_id              = local.common_windows_config.aws_vpc_id
  azs                     = local.common_windows_config.azs
  dns_zone_id             = local.common_windows_config.dns_zone_id
  dns_suffix              = local.common_windows_config.dns_suffix

  # Common instance configuration
  common_instance_metadata_options    = local.common_instance_metadata_options
  common_instance_root_block_device   = local.common_instance_root_block_device

  # Service-specific configuration
  aws_number            = var.aws_number["rdsh"]
  aws_subnet_id         = var.aws_subnet_back_id
  aws_sg_domain_members = aws_security_group.domain-member.id

  # Use computed CIDR blocks from root locals
  cidr = local.cidr_blocks.back

  # Security groups with service-specific additions
  aws_sg_ids = flatten([
    local.back_subnet_sg_ids,
    module.rdsh.aws_sg_rdsh_id,
  ])
}

module "sharepoint" {
  source = "./sharepoint"

  # Common Windows configuration
  aws_ami                 = local.common_windows_config.aws_ami
  aws_iip_assumerole_name = local.common_windows_config.aws_iip_assumerole_name
  aws_key_pair_auth_id    = local.common_windows_config.aws_key_pair_auth_id
  aws_region              = local.common_windows_config.aws_region
  aws_vpc_id              = local.common_windows_config.aws_vpc_id
  azs                     = local.common_windows_config.azs
  dns_zone_id             = local.common_windows_config.dns_zone_id
  dns_suffix              = local.common_windows_config.dns_suffix

  # Common instance configuration
  common_instance_metadata_options    = local.common_instance_metadata_options
  common_instance_root_block_device   = local.common_instance_root_block_device

  # Service-specific configuration
  aws_number    = var.aws_number["sharepoint"]
  aws_subnet_id = var.aws_subnet_web_id

  # Use computed CIDR blocks from root locals
  cidr = local.cidr_blocks.web

  # Security groups with service-specific additions
  aws_sg_ids = flatten([
    local.web_subnet_sg_ids,
    module.sharepoint.aws_sg_sharepoint_id,
  ])
}

module "sql" {
  source = "./sql"

  # SQL uses a different AMI (SQL Server 2019)
  aws_ami = data.aws_ami.sql2019.id

  # Common Windows configuration (except AMI)
  aws_iip_assumerole_name = local.common_windows_config.aws_iip_assumerole_name
  aws_key_pair_auth_id    = local.common_windows_config.aws_key_pair_auth_id
  aws_region              = local.common_windows_config.aws_region
  aws_vpc_id              = local.common_windows_config.aws_vpc_id
  azs                     = local.common_windows_config.azs
  dns_zone_id             = local.common_windows_config.dns_zone_id
  dns_suffix              = local.common_windows_config.dns_suffix

  # Common instance configuration
  common_instance_metadata_options    = local.common_instance_metadata_options
  common_instance_root_block_device   = local.common_instance_root_block_device

  # Service-specific configuration
  aws_number    = var.aws_number["sql"]
  aws_subnet_id = var.aws_subnet_back_id

  # Use computed CIDR blocks from root locals
  cidr = local.cidr_blocks.sql

  # Security groups with service-specific additions
  aws_sg_ids = flatten([
    local.back_subnet_sg_ids,
    module.sql.aws_sg_sql_id,
  ])
}

module "workfolders" {
  source = "./workfolders"
}

module "simpana" {
  source = "./simpana"

  # Common Windows configuration
  aws_ami                 = local.common_windows_config.aws_ami
  aws_iip_assumerole_name = local.common_windows_config.aws_iip_assumerole_name
  aws_key_pair_auth_id    = local.common_windows_config.aws_key_pair_auth_id
  aws_region              = local.common_windows_config.aws_region
  aws_vpc_id              = local.common_windows_config.aws_vpc_id
  azs                     = local.common_windows_config.azs
  dns_zone_id             = local.common_windows_config.dns_zone_id
  dns_suffix              = local.common_windows_config.dns_suffix

  # Common instance configuration
  common_instance_metadata_options    = local.common_instance_metadata_options
  common_instance_root_block_device   = local.common_instance_root_block_device

  # Service-specific configuration
  aws_number    = var.aws_number["simpana"]
  aws_subnet_id = var.aws_subnet_backup_id

  # Use computed CIDR blocks from root locals
  cidr = local.cidr_blocks.back

  # Security groups (simpana doesn't include its own client ID in the list)
  aws_sg_ids = flatten([
    aws_security_group.rdp.id,
    aws_security_group.domain-member.id,
  ])
}

module "sofs" {
  source = "./sofs"

  # Common Windows configuration
  aws_ami                 = local.common_windows_config.aws_ami
  aws_iip_assumerole_name = local.common_windows_config.aws_iip_assumerole_name
  aws_key_pair_auth_id    = local.common_windows_config.aws_key_pair_auth_id
  aws_region              = local.common_windows_config.aws_region
  aws_vpc_id              = local.common_windows_config.aws_vpc_id
  azs                     = local.common_windows_config.azs
  dns_zone_id             = local.common_windows_config.dns_zone_id
  dns_suffix              = local.common_windows_config.dns_suffix

  # Common instance configuration
  common_instance_metadata_options    = local.common_instance_metadata_options
  common_instance_root_block_device   = local.common_instance_root_block_device

  # Service-specific configuration
  aws_number            = var.aws_number["sofs"]
  aws_subnet_id         = var.aws_subnet_back_id
  aws_sg_domain_members = aws_security_group.domain-member.id

  # Use computed CIDR blocks from root locals
  cidr = local.cidr_blocks.back

  # Security groups with service-specific additions
  aws_sg_ids = flatten([
    local.back_subnet_sg_ids,
    module.sofs.aws_sg_sofs_id,
  ])
}

module "wac" {
  source = "./wac"

  # Common Windows configuration
  aws_ami                 = local.common_windows_config.aws_ami
  aws_iip_assumerole_name = local.common_windows_config.aws_iip_assumerole_name
  aws_key_pair_auth_id    = local.common_windows_config.aws_key_pair_auth_id
  aws_region              = local.common_windows_config.aws_region
  aws_vpc_id              = local.common_windows_config.aws_vpc_id
  azs                     = local.common_windows_config.azs
  dns_zone_id             = local.common_windows_config.dns_zone_id
  dns_suffix              = local.common_windows_config.dns_suffix

  # Common instance configuration
  common_instance_metadata_options    = local.common_instance_metadata_options
  common_instance_root_block_device   = local.common_instance_root_block_device

  # Service-specific configuration
  aws_number    = var.aws_number["wac"]
  aws_subnet_id = var.aws_subnet_back_id

  # Use computed CIDR blocks from root locals
  cidr = local.cidr_blocks.mgmt

  # Security groups with service-specific additions
  aws_sg_ids = flatten([
    local.back_subnet_sg_ids,
    module.wac.aws_sg_wac_id,
  ])
}

module "wds" {
  source = "./wds"

  # Common Windows configuration
  aws_ami                 = local.common_windows_config.aws_ami
  aws_iip_assumerole_name = local.common_windows_config.aws_iip_assumerole_name
  aws_key_pair_auth_id    = local.common_windows_config.aws_key_pair_auth_id
  aws_region              = local.common_windows_config.aws_region
  aws_vpc_id              = local.common_windows_config.aws_vpc_id
  azs                     = local.common_windows_config.azs
  dns_zone_id             = local.common_windows_config.dns_zone_id
  dns_suffix              = local.common_windows_config.dns_suffix

  # Common instance configuration
  common_instance_metadata_options    = local.common_instance_metadata_options
  common_instance_root_block_device   = local.common_instance_root_block_device

  # Service-specific configuration
  aws_number    = var.aws_number["wds"]
  aws_subnet_id = var.aws_subnet_back_id

  # Use computed CIDR blocks from root locals
  cidr = local.cidr_blocks.backup

  # Security groups with service-specific additions
  aws_sg_ids = flatten([
    local.back_subnet_sg_ids,
    module.wds.aws_sg_wds_id,
  ])
}

module "wsus" {
  source = "./wsus"

  # Common Windows configuration
  aws_ami                 = local.common_windows_config.aws_ami
  aws_iip_assumerole_name = local.common_windows_config.aws_iip_assumerole_name
  aws_key_pair_auth_id    = local.common_windows_config.aws_key_pair_auth_id
  aws_region              = local.common_windows_config.aws_region
  aws_vpc_id              = local.common_windows_config.aws_vpc_id
  azs                     = local.common_windows_config.azs
  dns_zone_id             = local.common_windows_config.dns_zone_id
  dns_suffix              = local.common_windows_config.dns_suffix

  # Common instance configuration
  common_instance_metadata_options    = local.common_instance_metadata_options
  common_instance_root_block_device   = local.common_instance_root_block_device

  # Service-specific configuration
  aws_number    = var.aws_number["wsus"]
  aws_subnet_id = var.aws_subnet_back_id

  # Use computed CIDR blocks from root locals
  cidr = local.cidr_blocks.backup

  # Security groups with service-specific additions
  aws_sg_ids = flatten([
    local.back_subnet_sg_ids,
    module.wsus.aws_sg_wsus_id,
  ])
}

resource "aws_security_group" "rdp" {
  name        = "tf_ezlab_rdp"
  description = "Security group for Windows administrative access (RDP, SSH, WinRM)"
  vpc_id      = var.aws_vpc_id

  # RDP access from restricted CIDR blocks
  ingress {
    description = "Allow RDP from admin CIDR blocks"
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = var.admin_cidr_blocks
  }

  # SSH access from restricted CIDR blocks
  ingress {
    description = "Allow SSH from admin CIDR blocks"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.admin_cidr_blocks
  }

  # WinRM access from restricted CIDR blocks
  ingress {
    description = "Allow WinRM (HTTP and HTTPS) from admin CIDR blocks"
    from_port   = 5985
    to_port     = 5986
    protocol    = "tcp"
    cidr_blocks = var.admin_cidr_blocks
  }

  # Dynamic egress rules - eliminates code duplication
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

resource "aws_security_group" "domain-member" {
  name        = "tf_ezlab_domain_member"
  description = "Security group for Active Directory domain member traffic"
  vpc_id      = var.aws_vpc_id

  # ICMP ping for connectivity testing
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

  # Kerberos authentication (TCP and UDP)
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

  # NTP for time synchronization
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

  # SMB/CIFS file sharing (TCP and UDP)
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

  # LDAPS (secure LDAP)
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

  # WinRM for remote management
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

  # FusionInventory agent (IPv4)
  ingress {
    description = "Allow FusionInventory agent from VPC"
    from_port   = 62354
    to_port     = 62354
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  # FusionInventory agent (IPv6)
  ingress {
    description      = "Allow FusionInventory agent from IPv6"
    from_port        = 62354
    to_port          = 62354
    protocol         = "tcp"
    ipv6_cidr_blocks = ["::/0"]
  }

  # Dynamic egress rules - eliminates code duplication
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
  owners = ["801119661308"] # Canonical
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
    values = ["Windows_Server-2019-English-Full-SQL_2019_Standard-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["801119661308"] # Canonical
}
data "aws_ami" "windows2016" {
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
data "aws_ami" "sql2017" {
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
