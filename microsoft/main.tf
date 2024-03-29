module "adcs" {
  source                  = "./adcs"
  aws_ami                 = data.aws_ami.windows2022.id
  aws_iip_assumerole_name = var.aws_iip_assumerole_name
  aws_key_pair_auth_id    = var.aws_key_pair_auth_id
  aws_number_pki-crl      = var.aws_number["pki-crl"]
  aws_number_pki-ica      = var.aws_number["pki-ica"]
  aws_number_pki-rca      = var.aws_number["pki-rca"]
  aws_number_pki-ndes     = var.aws_number["pki-ndes"]
  aws_subnet_id           = var.aws_subnet_back_id
  aws_vpc_id              = var.aws_vpc_id
  dns_zone_id             = var.dns_zone_id
  dns_suffix              = var.dns_suffix
  azs                     = var.azs

  cidr = [
    cidrsubnet(var.vpc_cidr, 8, var.cidrbyte["back1.${var.aws_region}"]),
    cidrsubnet(var.vpc_cidr, 8, var.cidrbyte["back2.${var.aws_region}"]),
    cidrsubnet(var.vpc_cidr, 8, var.cidrbyte["back3.${var.aws_region}"]),
  ]



  aws_sg_ids = flatten([
    aws_security_group.rdp.id,
    aws_security_group.domain-member.id,
    module.adcs.aws_sg_pki-crl_ids,
    module.adcs.aws_sg_pki-ica_ids,
    module.adcs.aws_sg_pki-rca_ids,
    module.simpana.aws_sg_client_id,
    var.aws_sg_nbuclient_ids,
  ])
}

module "adds" {
  source                  = "./adds"
  aws_ami                 = data.aws_ami.windows2022.id
  aws_iip_assumerole_name = var.aws_iip_assumerole_name
  aws_key_pair_auth_id    = var.aws_key_pair_auth_id
  aws_number              = var.aws_number["dc"]
  aws_region              = var.aws_region
  aws_subnet_id           = var.aws_subnet_back_id
  aws_vpc_id              = var.aws_vpc_id
  azs                     = var.azs
  dns_zone_id             = var.dns_zone_id
  dns_suffix              = var.dns_suffix

  cidr = [
    cidrsubnet(var.vpc_cidr, 8, var.cidrbyte["back1.${var.aws_region}"]),
    cidrsubnet(var.vpc_cidr, 8, var.cidrbyte["back2.${var.aws_region}"]),
    cidrsubnet(var.vpc_cidr, 8, var.cidrbyte["back3.${var.aws_region}"]),
  ]

  aws_sg_ids = flatten([
    aws_security_group.rdp.id,
    aws_security_group.domain-member.id,
    module.adds.aws_sg_dc_id,
    module.simpana.aws_sg_client_id,
    var.aws_sg_nbuclient_ids,
  ])

  aws_sg_domain_member = aws_security_group.domain-member.id
}

module "adfs" {
  source                  = "./adfs"
  aws_ami                 = data.aws_ami.windows2022.id
  aws_iip_assumerole_name = var.aws_iip_assumerole_name
  aws_key_pair_auth_id    = var.aws_key_pair_auth_id
  aws_number              = var.aws_number["adfs"]
  aws_region              = var.aws_region
  aws_subnet_id           = var.aws_subnet_web_id
  aws_vpc_id              = var.aws_vpc_id
  azs                     = var.azs
  dns_zone_id             = var.dns_zone_id
  dns_suffix              = var.dns_suffix

  cidr = [
    cidrsubnet(var.vpc_cidr, 8, var.cidrbyte["web1.${var.aws_region}"]),
    cidrsubnet(var.vpc_cidr, 8, var.cidrbyte["web2.${var.aws_region}"]),
    cidrsubnet(var.vpc_cidr, 8, var.cidrbyte["web3.${var.aws_region}"]),
  ]

  aws_sg_ids = flatten([
    aws_security_group.rdp.id,
    aws_security_group.domain-member.id,
    module.adds.aws_sg_dc_id,
    module.simpana.aws_sg_client_id,
    var.aws_sg_nbuclient_ids,
  ])
}

# module "dfs" {
#   source = "./dfs"
# }

module "dhcp" {
  source                  = "./dhcp"
  aws_ami                 = data.aws_ami.windows2022.id
  aws_iip_assumerole_name = var.aws_iip_assumerole_name
  aws_key_pair_auth_id    = var.aws_key_pair_auth_id
  aws_number              = var.aws_number["dhcp"]
  aws_region              = var.aws_region
  aws_subnet_id           = var.aws_subnet_back_id
  aws_vpc_id              = var.aws_vpc_id
  azs                     = var.azs
  dns_zone_id             = var.dns_zone_id
  dns_suffix              = var.dns_suffix

  cidr = [
    cidrsubnet(var.vpc_cidr, 8, var.cidrbyte["back1.${var.aws_region}"]),
    cidrsubnet(var.vpc_cidr, 8, var.cidrbyte["back2.${var.aws_region}"]),
    cidrsubnet(var.vpc_cidr, 8, var.cidrbyte["back3.${var.aws_region}"]),
  ]

  aws_sg_ids = flatten([
    aws_security_group.rdp.id,
    module.dhcp.aws_sg_dhcp_id,
    aws_security_group.domain-member.id,
    module.simpana.aws_sg_client_id,
    var.aws_sg_nbuclient_ids,
  ])
}

module "da" {
  source                  = "./da"
  aws_ami                 = data.aws_ami.windows2022.id
  aws_iip_assumerole_name = var.aws_iip_assumerole_name
  aws_key_pair_auth_id    = var.aws_key_pair_auth_id
  aws_number              = var.aws_number["da"]
  aws_region              = var.aws_region
  aws_subnet_id           = var.aws_subnet_mgmt_id
  aws_vpc_id              = var.aws_vpc_id
  azs                     = var.azs
  dns_zone_id             = var.dns_zone_id
  dns_suffix              = var.dns_suffix

  cidr = [
    cidrsubnet(var.vpc_cidr, 8, var.cidrbyte["web1.${var.aws_region}"]),
    cidrsubnet(var.vpc_cidr, 8, var.cidrbyte["web2.${var.aws_region}"]),
    cidrsubnet(var.vpc_cidr, 8, var.cidrbyte["web3.${var.aws_region}"]),
  ]

  aws_sg_ids = flatten([
    aws_security_group.rdp.id,
    aws_security_group.domain-member.id,
    module.da.aws_sg_da_id,
    module.simpana.aws_sg_client_id,
    var.aws_sg_nbuclient_ids,
  ])
}

module "exchange" {
  source                  = "./exchange"
  aws_ami                 = data.aws_ami.windows2022.id
  aws_iip_assumerole_name = var.aws_iip_assumerole_name
  aws_key_pair_auth_id    = var.aws_key_pair_auth_id
  aws_number              = var.aws_number["exchange"]
  aws_region              = var.aws_region
  aws_subnet_id           = var.aws_subnet_exchange_id
  aws_vpc_id              = var.aws_vpc_id
  azs                     = var.azs
  dns_zone_id             = var.dns_zone_id
  dns_suffix              = var.dns_suffix

  cidr = [
    cidrsubnet(var.vpc_cidr, 8, var.cidrbyte["exchange1.${var.aws_region}"]),
    cidrsubnet(var.vpc_cidr, 8, var.cidrbyte["exchange2.${var.aws_region}"]),
    cidrsubnet(var.vpc_cidr, 8, var.cidrbyte["exchange3.${var.aws_region}"]),
  ]

  aws_sg_ids = flatten([
    aws_security_group.rdp.id,
    aws_security_group.domain-member.id,
    module.exchange.aws_sg_exchange_id,
    module.simpana.aws_sg_client_id,
    var.aws_sg_nbuclient_ids,
  ])
}

module "fs" {
  source                  = "./fs"
  aws_ami                 = data.aws_ami.windows2022.id
  aws_iip_assumerole_name = var.aws_iip_assumerole_name
  aws_key_pair_auth_id    = var.aws_key_pair_auth_id
  aws_number              = var.aws_number["fs"]
  aws_region              = var.aws_region
  aws_subnet_id           = var.aws_subnet_back_id
  aws_vpc_id              = var.aws_vpc_id
  azs                     = var.azs
  dns_zone_id             = var.dns_zone_id
  dns_suffix              = var.dns_suffix

  cidr = [
    cidrsubnet(var.vpc_cidr, 8, var.cidrbyte["back1.${var.aws_region}"]),
    cidrsubnet(var.vpc_cidr, 8, var.cidrbyte["back2.${var.aws_region}"]),
    cidrsubnet(var.vpc_cidr, 8, var.cidrbyte["back3.${var.aws_region}"]),
  ]

  aws_sg_ids = flatten([
    aws_security_group.rdp.id,
    module.fs.aws_sg_fs_id,
    aws_security_group.domain-member.id,
    module.simpana.aws_sg_client_id,
    var.aws_sg_nbuclient_ids,
  ])

  aws_sg_domain_members = aws_security_group.domain-member.id
}

module "ipam" {
  source                  = "./ipam/"
  aws_ami                 = data.aws_ami.windows2022.id
  aws_iip_assumerole_name = var.aws_iip_assumerole_name
  aws_key_pair_auth_id    = var.aws_key_pair_auth_id
  aws_number              = var.aws_number["ipam"]
  aws_region              = var.aws_region
  aws_subnet_id           = var.aws_subnet_back_id
  aws_vpc_id              = var.aws_vpc_id
  azs                     = var.azs
  dns_zone_id             = var.dns_zone_id
  dns_suffix              = var.dns_suffix

  cidr = [
    cidrsubnet(var.vpc_cidr, 8, var.cidrbyte["back1.${var.aws_region}"]),
    cidrsubnet(var.vpc_cidr, 8, var.cidrbyte["back2.${var.aws_region}"]),
    cidrsubnet(var.vpc_cidr, 8, var.cidrbyte["back3.${var.aws_region}"]),
  ]

  aws_sg_ids = flatten([
    aws_security_group.rdp.id,
    aws_security_group.domain-member.id,
    module.ipam.aws_sg_ipam_id,
    module.simpana.aws_sg_client_id,
    var.aws_sg_nbuclient_ids,
  ])
}

module "mgmt" {
  source                  = "./mgmt"
  aws_ami                 = data.aws_ami.windows2022.id
  aws_iip_assumerole_name = var.aws_iip_assumerole_name
  aws_key_pair_auth_id    = var.aws_key_pair_auth_id
  aws_number              = var.aws_number["mgmt"]
  aws_region              = var.aws_region
  aws_subnet_id           = var.aws_subnet_mgmt_id
  aws_vpc_id              = var.aws_vpc_id
  azs                     = var.azs
  dns_zone_id             = var.dns_zone_id
  dns_public_zone_id      = var.dns_public_zone_id
  dns_suffix              = var.dns_suffix

  aws_sg_ids = flatten([
    aws_security_group.rdp.id,
    aws_security_group.domain-member.id,
    module.simpana.aws_sg_client_id,
    var.aws_sg_nbuclient_ids,
  ])
}

module "nps" {
  source                  = "./nps"
  aws_ami                 = data.aws_ami.windows2022.id
  aws_iip_assumerole_name = var.aws_iip_assumerole_name
  aws_key_pair_auth_id    = var.aws_key_pair_auth_id
  aws_number              = var.aws_number["nps"]
  aws_region              = var.aws_region
  aws_subnet_id           = var.aws_subnet_back_id
  aws_vpc_id              = var.aws_vpc_id
  azs                     = var.azs
  dns_zone_id             = var.dns_zone_id
  dns_suffix              = var.dns_suffix

  cidr = [
    cidrsubnet(var.vpc_cidr, 8, var.cidrbyte["back1.${var.aws_region}"]),
    cidrsubnet(var.vpc_cidr, 8, var.cidrbyte["back2.${var.aws_region}"]),
    cidrsubnet(var.vpc_cidr, 8, var.cidrbyte["back3.${var.aws_region}"]),
  ]

  aws_sg_ids = flatten([
    aws_security_group.rdp.id,
    aws_security_group.domain-member.id,
    module.nps.aws_sg_nps_id,
    module.simpana.aws_sg_client_id,
    var.aws_sg_nbuclient_ids,
  ])
}

module "rdsh" {
  source                  = "./rdsh"
  aws_ami                 = data.aws_ami.windows2022.id
  aws_iip_assumerole_name = var.aws_iip_assumerole_name
  aws_key_pair_auth_id    = var.aws_key_pair_auth_id
  aws_number              = var.aws_number["rdsh"]
  aws_region              = var.aws_region
  aws_subnet_id           = var.aws_subnet_back_id
  aws_vpc_id              = var.aws_vpc_id
  azs                     = var.azs
  dns_zone_id             = var.dns_zone_id
  dns_suffix              = var.dns_suffix
  aws_sg_domain_members   = aws_security_group.domain-member.id

  cidr = [
    cidrsubnet(var.vpc_cidr, 8, var.cidrbyte["back1.${var.aws_region}"]),
    cidrsubnet(var.vpc_cidr, 8, var.cidrbyte["back2.${var.aws_region}"]),
    cidrsubnet(var.vpc_cidr, 8, var.cidrbyte["back3.${var.aws_region}"]),
  ]

  aws_sg_ids = flatten([
    aws_security_group.rdp.id,
    aws_security_group.domain-member.id,
    module.rdsh.aws_sg_rdsh_id,
    module.simpana.aws_sg_client_id,
    var.aws_sg_nbuclient_ids,
  ])
}

module "sharepoint" {
  source                  = "./sharepoint"
  aws_ami                 = data.aws_ami.windows2022.id
  aws_iip_assumerole_name = var.aws_iip_assumerole_name
  aws_key_pair_auth_id    = var.aws_key_pair_auth_id
  aws_number              = var.aws_number["sharepoint"]
  aws_region              = var.aws_region
  aws_subnet_id           = var.aws_subnet_web_id
  aws_vpc_id              = var.aws_vpc_id
  azs                     = var.azs
  dns_zone_id             = var.dns_zone_id
  dns_suffix              = var.dns_suffix

  cidr = [
    cidrsubnet(var.vpc_cidr, 8, var.cidrbyte["web1.${var.aws_region}"]),
    cidrsubnet(var.vpc_cidr, 8, var.cidrbyte["web2.${var.aws_region}"]),
    cidrsubnet(var.vpc_cidr, 8, var.cidrbyte["web3.${var.aws_region}"]),
  ]

  aws_sg_ids = flatten([
    aws_security_group.rdp.id,
    aws_security_group.domain-member.id,
    module.sharepoint.aws_sg_sharepoint_id,
    module.simpana.aws_sg_client_id,
    var.aws_sg_nbuclient_ids,
  ])
}

module "sql" {
  source                  = "./sql"
  aws_ami                 = data.aws_ami.sql2019.id
  aws_iip_assumerole_name = var.aws_iip_assumerole_name
  aws_key_pair_auth_id    = var.aws_key_pair_auth_id
  aws_number              = var.aws_number["sql"]
  aws_region              = var.aws_region
  aws_subnet_id           = var.aws_subnet_back_id
  aws_vpc_id              = var.aws_vpc_id
  azs                     = var.azs
  dns_zone_id             = var.dns_zone_id
  dns_suffix              = var.dns_suffix

  cidr = [
    cidrsubnet(var.vpc_cidr, 8, var.cidrbyte["sql1.${var.aws_region}"]),
    cidrsubnet(var.vpc_cidr, 8, var.cidrbyte["sql2.${var.aws_region}"]),
    cidrsubnet(var.vpc_cidr, 8, var.cidrbyte["sql3.${var.aws_region}"]),
  ]

  aws_sg_ids = flatten([
    aws_security_group.rdp.id,
    aws_security_group.domain-member.id,
    module.simpana.aws_sg_client_id,
    module.sql.aws_sg_sql_id,
    var.aws_sg_nbuclient_ids,
  ])
}

module "workfolders" {
  source = "./workfolders"
}

module "simpana" {
  source                  = "./simpana"
  aws_ami                 = data.aws_ami.windows2022.id
  aws_iip_assumerole_name = var.aws_iip_assumerole_name
  aws_key_pair_auth_id    = var.aws_key_pair_auth_id
  aws_number              = var.aws_number["simpana"]
  aws_region              = var.aws_region
  aws_subnet_id           = var.aws_subnet_backup_id
  aws_vpc_id              = var.aws_vpc_id
  azs                     = var.azs
  dns_zone_id             = var.dns_zone_id
  dns_suffix              = var.dns_suffix

  cidr = [
    cidrsubnet(var.vpc_cidr, 8, var.cidrbyte["back1.${var.aws_region}"]),
    cidrsubnet(var.vpc_cidr, 8, var.cidrbyte["back2.${var.aws_region}"]),
    cidrsubnet(var.vpc_cidr, 8, var.cidrbyte["back3.${var.aws_region}"]),
  ]

  aws_sg_ids = flatten([
    aws_security_group.rdp.id,
    aws_security_group.domain-member.id,
    # module.simpana.aws_sg_client_id,
  ])
}

module "sofs" {
  source                  = "./sofs"
  aws_ami                 = data.aws_ami.windows2022.id
  aws_iip_assumerole_name = var.aws_iip_assumerole_name
  aws_key_pair_auth_id    = var.aws_key_pair_auth_id
  aws_number              = var.aws_number["sofs"]
  aws_region              = var.aws_region
  aws_subnet_id           = var.aws_subnet_back_id
  aws_vpc_id              = var.aws_vpc_id
  azs                     = var.azs
  dns_zone_id             = var.dns_zone_id
  dns_suffix              = var.dns_suffix

  cidr = [
    cidrsubnet(var.vpc_cidr, 8, var.cidrbyte["back1.${var.aws_region}"]),
    cidrsubnet(var.vpc_cidr, 8, var.cidrbyte["back2.${var.aws_region}"]),
    cidrsubnet(var.vpc_cidr, 8, var.cidrbyte["back3.${var.aws_region}"]),
  ]

  aws_sg_ids = flatten([
    aws_security_group.rdp.id,
    module.sofs.aws_sg_sofs_id,
    aws_security_group.domain-member.id,
    module.simpana.aws_sg_client_id,
    var.aws_sg_nbuclient_ids,
  ])

  aws_sg_domain_members = aws_security_group.domain-member.id
}

module "wac" {
  source                  = "./wac"
  aws_ami                 = data.aws_ami.windows2022.id
  aws_iip_assumerole_name = var.aws_iip_assumerole_name
  aws_key_pair_auth_id    = var.aws_key_pair_auth_id
  aws_number              = var.aws_number["wac"]
  aws_region              = var.aws_region
  aws_subnet_id           = var.aws_subnet_back_id
  aws_vpc_id              = var.aws_vpc_id
  azs                     = var.azs
  dns_zone_id             = var.dns_zone_id
  dns_suffix              = var.dns_suffix

  aws_sg_ids = flatten([
    aws_security_group.rdp.id,
    aws_security_group.domain-member.id,
    module.simpana.aws_sg_client_id,
    module.wac.aws_sg_wac_id,
    var.aws_sg_nbuclient_ids,
  ])

  cidr = [
    cidrsubnet(var.vpc_cidr, 8, var.cidrbyte["mgmt1.${var.aws_region}"]),
    cidrsubnet(var.vpc_cidr, 8, var.cidrbyte["mgmt2.${var.aws_region}"]),
    cidrsubnet(var.vpc_cidr, 8, var.cidrbyte["mgmt3.${var.aws_region}"]),
  ]
}

module "wds" {
  source                  = "./wds"
  aws_ami                 = data.aws_ami.windows2022.id
  aws_iip_assumerole_name = var.aws_iip_assumerole_name
  aws_key_pair_auth_id    = var.aws_key_pair_auth_id
  aws_number              = var.aws_number["wds"]
  aws_region              = var.aws_region
  aws_subnet_id           = var.aws_subnet_back_id
  aws_vpc_id              = var.aws_vpc_id
  azs                     = var.azs
  dns_zone_id             = var.dns_zone_id
  dns_suffix              = var.dns_suffix

  aws_sg_ids = flatten([
    aws_security_group.rdp.id,
    aws_security_group.domain-member.id,
    module.simpana.aws_sg_client_id,
    module.wds.aws_sg_wds_id,
    var.aws_sg_nbuclient_ids,
  ])

  cidr = [
    cidrsubnet(var.vpc_cidr, 8, var.cidrbyte["backup1.${var.aws_region}"]),
    cidrsubnet(var.vpc_cidr, 8, var.cidrbyte["backup2.${var.aws_region}"]),
    cidrsubnet(var.vpc_cidr, 8, var.cidrbyte["backup3.${var.aws_region}"]),
  ]
}

module "wsus" {
  source                  = "./wsus"
  aws_ami                 = data.aws_ami.windows2022.id
  aws_iip_assumerole_name = var.aws_iip_assumerole_name
  aws_key_pair_auth_id    = var.aws_key_pair_auth_id
  aws_number              = var.aws_number["wsus"]
  aws_region              = var.aws_region
  aws_subnet_id           = var.aws_subnet_back_id
  aws_vpc_id              = var.aws_vpc_id
  azs                     = var.azs
  dns_zone_id             = var.dns_zone_id
  dns_suffix              = var.dns_suffix

  aws_sg_ids = flatten([
    aws_security_group.rdp.id,
    aws_security_group.domain-member.id,
    module.simpana.aws_sg_client_id,
    module.wsus.aws_sg_wsus_id,
    var.aws_sg_nbuclient_ids,
  ])

  cidr = [
    cidrsubnet(var.vpc_cidr, 8, var.cidrbyte["backup1.${var.aws_region}"]),
    cidrsubnet(var.vpc_cidr, 8, var.cidrbyte["backup2.${var.aws_region}"]),
    cidrsubnet(var.vpc_cidr, 8, var.cidrbyte["backup3.${var.aws_region}"]),
  ]
}

resource "aws_security_group" "rdp" {
  name        = "tf_ezlab_rdp"
  description = "Used in the terraform"
  vpc_id      = var.aws_vpc_id

  # HTTP access from anywhere
  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5985
    to_port     = 5986
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_security_group" "domain-member" {
  name        = "tf_ezlab_domain_member"
  description = "Allow Domain membteer traffic"
  vpc_id      = var.aws_vpc_id

  # DNS (53/tcp and 53/udp)
  # Kerberos-Adm (UDP) (749/udp)
  # Kerberos-Sec (TCP) (88/tcp)
  # Kerberos-Sec (UDP) (88/udp)
  # LDAP (389/tcp)
  # LDAP UDP (389/udp)
  # LDAP GC (Global Catalog) (3268/tcp)
  # Microsoft CIFS (TCP) (445/tcp)
  # Microsoft CIFS (UDP) (445/udp)
  # NTP (UDP) (123/udp)
  # PING (ICMP Type 8)
  # RPC (all interfaces) (135/tcp)

  ingress {
    description = "ping"
    from_port   = 8
    to_port     = 8
    protocol    = "icmp"
    self        = true
  }
  ingress {
    description = "Kerberos-Adm"
    from_port   = 749
    to_port     = 749
    protocol    = "udp"
    self        = true
  }
  ingress {
    description = "RPC"
    from_port   = 135
    to_port     = 135
    protocol    = "tcp"
    self        = true
  }
  ingress {
    description = "ntp"
    from_port   = 123
    to_port     = 123
    protocol    = "udp"
    self        = true
  }
  ingress {
    description = "SMB"
    from_port   = 445
    to_port     = 445
    protocol    = "tcp"
    self        = true
  }
  ingress {
    description = "SMB"
    from_port   = 445
    to_port     = 445
    protocol    = "udp"
    self        = true
  }
  ingress {
    description = "LDAP GC"
    from_port   = 3268
    to_port     = 3269
    protocol    = "tcp"
    self        = true
  }
  ingress {
    description = "LDAPS"
    from_port   = 636
    to_port     = 636
    protocol    = "tcp"
    self        = true
  }
  ingress {
    description = "LDAPS"
    from_port   = 636
    to_port     = 636
    protocol    = "udp"
    self        = true
  }
  ingress {
    description = "LDAP"
    from_port   = 389
    to_port     = 389
    protocol    = "tcp"
    self        = true
  }
  ingress {
    description = "LDAP"
    from_port   = 389
    to_port     = 389
    protocol    = "udp"
    self        = true
  }
  ingress {
    description = "kerberos"
    from_port   = 88
    to_port     = 88
    protocol    = "tcp"
    self        = true
  }
  ingress {
    description = "kerberos"
    from_port   = 88
    to_port     = 88
    protocol    = "udp"
    self        = true
  }
  ingress {
    description = "dns"
    from_port   = 53
    to_port     = 53
    protocol    = "tcp"
    self        = true
  }
  ingress {
    description = "dns"
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    self        = true
  }
  ingress {
    description = "winrm"
    from_port   = 5985
    to_port     = 5986
    protocol    = "tcp"
    self        = true
  }
  ingress {
    description = "random"
    from_port   = 49152
    to_port     = 65535
    protocol    = "tcp"
    self        = true
  }
  ingress {
    description = "fusion-inventory"
    from_port   = 62354
    to_port     = 62354
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }
  ingress {
    description      = "fusion-inventory"
    from_port        = 62354
    to_port          = 62354
    protocol         = "tcp"
    ipv6_cidr_blocks = ["::/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    ipv6_cidr_blocks = ["::/0"]
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
