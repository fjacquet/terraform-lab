module "adcs" {
  source                  = "./adcs"
  aws_ami                 = "${lookup(var.aws_amis , "win2016")}"
  aws_iip_assumerole_name = "${var.aws_iip_assumerole_name}"
  aws_key_pair_auth_id    = "${var.aws_key_pair_auth_id}"
  aws_number_pki_crl      = "${lookup(var.aws_number, "pki_crl")}"
  aws_number_pki_ica      = "${lookup(var.aws_number, "pki_ica")}"
  aws_number_pki_rca      = "${lookup(var.aws_number, "pki_rca")}"
  aws_region              = "${var.aws_region}"
  aws_subnet_id           = "${var.aws_subnet_back_id}"
  aws_vpc_id              = "${var.aws_vpc_id}"
  azs                     = "${var.azs}"

  cidr = [
    "${cidrsubnet(var.vpc_cidr,8,lookup(var.cidrbyte, "back1.${var.aws_region}"))}",
    "${cidrsubnet(var.vpc_cidr,8,lookup(var.cidrbyte, "back2.${var.aws_region}"))}",
    "${cidrsubnet(var.vpc_cidr,8,lookup(var.cidrbyte, "back3.${var.aws_region}"))}",
  ]

  aws_sg_ids = [
    "${aws_security_group.rdp.id}",
    "${aws_security_group.domain-member.id}",
    "${module.adcs.aws_sg_pki_crl_id}",
    "${module.adcs.aws_sg_pki_ica_id}",
    "${module.adcs.aws_sg_pki_rca_id}",
    "${module.simpana.aws_sg_client_id}",
    "${var.aws_sg_nbuclient_id}",
  ]
}

module "adds" {
  source                  = "./adds"
  aws_ami                 = "${lookup(var.aws_amis , "win2016")}"
  aws_iip_assumerole_name = "${var.aws_iip_assumerole_name}"
  aws_key_pair_auth_id    = "${var.aws_key_pair_auth_id}"
  aws_number              = "${lookup(var.aws_number, "dc")}"
  aws_region              = "${var.aws_region}"
  aws_subnet_id           = "${var.aws_subnet_back_id}"
  aws_vpc_id              = "${var.aws_vpc_id}"
  azs                     = "${var.azs}"

  cidr = [
    "${cidrsubnet(var.vpc_cidr,8,lookup(var.cidrbyte, "back1.${var.aws_region}"))}",
    "${cidrsubnet(var.vpc_cidr,8,lookup(var.cidrbyte, "back2.${var.aws_region}"))}",
    "${cidrsubnet(var.vpc_cidr,8,lookup(var.cidrbyte, "back3.${var.aws_region}"))}",
  ]

  aws_sg_ids = [
    "${aws_security_group.rdp.id}",
    "${aws_security_group.domain-member.id}",
    "${module.adds.aws_sg_dc_id}",
    "${module.simpana.aws_sg_client_id}",
    "${var.aws_sg_nbuclient_id}",
  ]
}

module "adfs" {
  source = "./adfs"
}

# module "dfs" {
#   source = "./dfs"
# }

module "dhcp" {
  source                  = "./dhcp"
  aws_ami                 = "${lookup(var.aws_amis , "win2016")}"
  aws_iip_assumerole_name = "${var.aws_iip_assumerole_name}"
  aws_key_pair_auth_id    = "${var.aws_key_pair_auth_id}"
  aws_number              = "${lookup(var.aws_number, "dhcp")}"
  aws_region              = "${var.aws_region}"
  aws_subnet_id           = "${var.aws_subnet_back_id}"
  aws_vpc_id              = "${var.aws_vpc_id}"
  azs                     = "${var.azs}"

  cidr = [
    "${cidrsubnet(var.vpc_cidr,8,lookup(var.cidrbyte, "back1.${var.aws_region}"))}",
    "${cidrsubnet(var.vpc_cidr,8,lookup(var.cidrbyte, "back2.${var.aws_region}"))}",
    "${cidrsubnet(var.vpc_cidr,8,lookup(var.cidrbyte, "back3.${var.aws_region}"))}",
  ]

  aws_sg_ids = [
    "${aws_security_group.rdp.id}",
    "${module.dhcp.aws_sg_dhcp_id}",
    "${aws_security_group.domain-member.id}",
    "${module.simpana.aws_sg_client_id}",
    "${var.aws_sg_nbuclient_id}",
  ]
}

module "da" {
  source                  = "./da"
  aws_ami                 = "${lookup(var.aws_amis , "win2016")}"
  aws_iip_assumerole_name = "${var.aws_iip_assumerole_name}"
  aws_key_pair_auth_id    = "${var.aws_key_pair_auth_id}"
  aws_number              = "${lookup(var.aws_number, "da")}"
  aws_region              = "${var.aws_region}"
  aws_subnet_id           = "${var.aws_subnet_mgmt_id}"
  aws_vpc_id              = "${var.aws_vpc_id}"
  azs                     = "${var.azs}"

  cidr = [
    "${cidrsubnet(var.vpc_cidr,8,lookup(var.cidrbyte, "web1.${var.aws_region}"))}",
    "${cidrsubnet(var.vpc_cidr,8,lookup(var.cidrbyte, "web2.${var.aws_region}"))}",
    "${cidrsubnet(var.vpc_cidr,8,lookup(var.cidrbyte, "web3.${var.aws_region}"))}",
  ]

  aws_sg_ids = [
    "${aws_security_group.rdp.id}",
    "${aws_security_group.domain-member.id}",
    "${module.da.aws_sg_da_id}",
    "${module.simpana.aws_sg_client_id}",
    "${var.aws_sg_nbuclient_id}",
  ]
}

module "exch" {
  source                  = "./exch"
  aws_ami                 = "${lookup(var.aws_amis , "win2016")}"
  aws_iip_assumerole_name = "${var.aws_iip_assumerole_name}"
  aws_key_pair_auth_id    = "${var.aws_key_pair_auth_id}"
  aws_number              = "${lookup(var.aws_number, "exch")}"
  aws_region              = "${var.aws_region}"
  aws_subnet_id           = "${var.aws_subnet_exch_id}"
  aws_vpc_id              = "${var.aws_vpc_id}"
  azs                     = "${var.azs}"

  cidr = [
    "${cidrsubnet(var.vpc_cidr,8,lookup(var.cidrbyte, "exch1.${var.aws_region}"))}",
    "${cidrsubnet(var.vpc_cidr,8,lookup(var.cidrbyte, "exch2.${var.aws_region}"))}",
    "${cidrsubnet(var.vpc_cidr,8,lookup(var.cidrbyte, "exch3.${var.aws_region}"))}",
  ]

  aws_sg_ids = [
    "${aws_security_group.rdp.id}",
    "${aws_security_group.domain-member.id}",
    "${module.exch.aws_sg_exch_id}",
    "${module.simpana.aws_sg_client_id}",
    "${var.aws_sg_nbuclient_id}",
  ]
}

module "fs" {
  source                  = "./fs"
  aws_ami                 = "${lookup(var.aws_amis , "win2016")}"
  aws_iip_assumerole_name = "${var.aws_iip_assumerole_name}"
  aws_key_pair_auth_id    = "${var.aws_key_pair_auth_id}"
  aws_number              = "${lookup(var.aws_number, "fs")}"
  aws_region              = "${var.aws_region}"
  aws_subnet_id           = "${var.aws_subnet_back_id}"
  aws_vpc_id              = "${var.aws_vpc_id}"
  azs                     = "${var.azs}"

  cidr = [
    "${cidrsubnet(var.vpc_cidr,8,lookup(var.cidrbyte, "back1.${var.aws_region}"))}",
    "${cidrsubnet(var.vpc_cidr,8,lookup(var.cidrbyte, "back2.${var.aws_region}"))}",
    "${cidrsubnet(var.vpc_cidr,8,lookup(var.cidrbyte, "back3.${var.aws_region}"))}",
  ]

  aws_sg_ids = [
    "${aws_security_group.rdp.id}",
    "${module.fs.aws_sg_fs_id}",
    "${aws_security_group.domain-member.id}",
    "${module.simpana.aws_sg_client_id}",
    "${var.aws_sg_nbuclient_id}",
  ]

  aws_sg_domain_members = "${aws_security_group.domain-member.id}"
}

module "ipam" {
  source                  = "./ipam/"
  aws_ami                 = "${lookup(var.aws_amis , "win2016")}"
  aws_iip_assumerole_name = "${var.aws_iip_assumerole_name}"
  aws_key_pair_auth_id    = "${var.aws_key_pair_auth_id}"
  aws_number              = "${lookup(var.aws_number, "ipam")}"
  aws_region              = "${var.aws_region}"
  aws_subnet_id           = "${var.aws_subnet_mgmt_id}"
  aws_vpc_id              = "${var.aws_vpc_id}"
  azs                     = "${var.azs}"

  cidr = [
    "${cidrsubnet(var.vpc_cidr,8,lookup(var.cidrbyte, "back1.${var.aws_region}"))}",
    "${cidrsubnet(var.vpc_cidr,8,lookup(var.cidrbyte, "back2.${var.aws_region}"))}",
    "${cidrsubnet(var.vpc_cidr,8,lookup(var.cidrbyte, "back3.${var.aws_region}"))}",
  ]

  aws_sg_ids = [
    "${aws_security_group.rdp.id}",
    "${aws_security_group.domain-member.id}",
    "${module.ipam.aws_sg_ipam_id}",
    "${module.simpana.aws_sg_client_id}",
    "${var.aws_sg_nbuclient_id}",
  ]
}

module "nps" {
  source                  = "./nps"
  aws_ami                 = "${lookup(var.aws_amis , "win2016")}"
  aws_iip_assumerole_name = "${var.aws_iip_assumerole_name}"
  aws_key_pair_auth_id    = "${var.aws_key_pair_auth_id}"
  aws_number              = "${lookup(var.aws_number, "nps")}"
  aws_region              = "${var.aws_region}"
  aws_subnet_id           = "${var.aws_subnet_back_id}"
  aws_vpc_id              = "${var.aws_vpc_id}"
  azs                     = "${var.azs}"

  cidr = [
    "${cidrsubnet(var.vpc_cidr,8,lookup(var.cidrbyte, "back1.${var.aws_region}"))}",
    "${cidrsubnet(var.vpc_cidr,8,lookup(var.cidrbyte, "back2.${var.aws_region}"))}",
    "${cidrsubnet(var.vpc_cidr,8,lookup(var.cidrbyte, "back3.${var.aws_region}"))}",
  ]

  aws_sg_ids = [
    "${aws_security_group.rdp.id}",
    "${aws_security_group.domain-member.id}",
    "${module.nps.aws_sg_nps_id}",
    "${module.simpana.aws_sg_client_id}",
    "${var.aws_sg_nbuclient_id}",
  ]
}

module "sharepoint" {
  source                  = "./sharepoint"
  aws_ami                 = "${lookup(var.aws_amis , "sharepoint")}"
  aws_iip_assumerole_name = "${var.aws_iip_assumerole_name}"
  aws_key_pair_auth_id    = "${var.aws_key_pair_auth_id}"
  aws_number              = "${lookup(var.aws_number, "sharepoint")}"
  aws_region              = "${var.aws_region}"
  aws_subnet_id           = "${var.aws_subnet_web_id}"
  aws_vpc_id              = "${var.aws_vpc_id}"
  azs                     = "${var.azs}"

  cidr = [
    "${cidrsubnet(var.vpc_cidr,8,lookup(var.cidrbyte, "web1.${var.aws_region}"))}",
    "${cidrsubnet(var.vpc_cidr,8,lookup(var.cidrbyte, "web2.${var.aws_region}"))}",
    "${cidrsubnet(var.vpc_cidr,8,lookup(var.cidrbyte, "web3.${var.aws_region}"))}",
  ]

  aws_sg_ids = [
    "${aws_security_group.rdp.id}",
    "${aws_security_group.domain-member.id}",
    "${module.sharepoint.aws_sg_sharepoint_id}",
    "${module.simpana.aws_sg_client_id}",
    "${var.aws_sg_nbuclient_id}",
  ]
}

module "sql" {
  source                  = "./sql"
  aws_ami                 = "${lookup(var.aws_amis , "sql")}"
  aws_iip_assumerole_name = "${var.aws_iip_assumerole_name}"
  aws_key_pair_auth_id    = "${var.aws_key_pair_auth_id}"
  aws_number              = "${lookup(var.aws_number, "sql")}"
  aws_region              = "${var.aws_region}"
  aws_subnet_id           = "${var.aws_subnet_back_id}"
  aws_vpc_id              = "${var.aws_vpc_id}"
  azs                     = "${var.azs}"

  cidr = [
    "${cidrsubnet(var.vpc_cidr,8,lookup(var.cidrbyte, "sql1.${var.aws_region}"))}",
    "${cidrsubnet(var.vpc_cidr,8,lookup(var.cidrbyte, "sql2.${var.aws_region}"))}",
    "${cidrsubnet(var.vpc_cidr,8,lookup(var.cidrbyte, "sql3.${var.aws_region}"))}",
  ]

  aws_sg_ids = [
    "${aws_security_group.rdp.id}",
    "${aws_security_group.domain-member.id}",
    "${module.simpana.aws_sg_client_id}",
    "${module.sql.aws_sg_sql_id}",
    "${var.aws_sg_nbuclient_id}",
  ]
}

module "workfolders" {
  source = "./workfolders"
}

module "simpana" {
  source                  = "./simpana"
  aws_ami                 = "${lookup(var.aws_amis , "win2016")}"
  aws_iip_assumerole_name = "${var.aws_iip_assumerole_name}"
  aws_key_pair_auth_id    = "${var.aws_key_pair_auth_id}"
  aws_number              = "${lookup(var.aws_number, "simpana")}"
  aws_region              = "${var.aws_region}"
  aws_subnet_id           = "${var.aws_subnet_backup_id}"
  aws_vpc_id              = "${var.aws_vpc_id}"
  azs                     = "${var.azs}"

  cidr = [
    "${cidrsubnet(var.vpc_cidr,8,lookup(var.cidrbyte, "backup1.${var.aws_region}"))}",
    "${cidrsubnet(var.vpc_cidr,8,lookup(var.cidrbyte, "backup2.${var.aws_region}"))}",
    "${cidrsubnet(var.vpc_cidr,8,lookup(var.cidrbyte, "backup3.${var.aws_region}"))}",
  ]

  aws_sg_ids = [
    "${aws_security_group.rdp.id}",
    "${module.simpana.aws_sg_client_id}",
  ]
}

module "jumpbox" {
  source                  = "./jumpbox"
  aws_ami                 = "${lookup(var.aws_amis , "jumpbox")}"
  aws_iip_assumerole_name = "${var.aws_iip_assumerole_name}"
  aws_key_pair_auth_id    = "${var.aws_key_pair_auth_id}"
  aws_number              = "${lookup(var.aws_number, "jumpbox")}"
  aws_region              = "${var.aws_region}"
  aws_subnet_id           = "${var.aws_subnet_mgmt_id}"
  aws_vpc_id              = "${var.aws_vpc_id}"
  azs                     = "${var.azs}"

  aws_sg_ids = [
    "${aws_security_group.rdp.id}",
    "${aws_security_group.domain-member.id}",
    "${module.simpana.aws_sg_client_id}",
    "${var.aws_sg_nbuclient_id}",
  ]
}

module "wsus" {
  source                  = "./wsus"
  aws_ami                 = "${lookup(var.aws_amis , "win2016")}"
  aws_iip_assumerole_name = "${var.aws_iip_assumerole_name}"
  aws_key_pair_auth_id    = "${var.aws_key_pair_auth_id}"
  aws_number              = "${lookup(var.aws_number, "wsus")}"
  aws_region              = "${var.aws_region}"
  aws_subnet_id           = "${var.aws_subnet_mgmt_id}"
  aws_vpc_id              = "${var.aws_vpc_id}"
  azs                     = "${var.azs}"

  aws_sg_ids = [
    "${aws_security_group.rdp.id}",
    "${aws_security_group.domain-member.id}",
    "${module.simpana.aws_sg_client_id}",
    "${module.wsus.aws_sg_wsus_id}",
    "${var.aws_sg_nbuclient_id}",
  ]

  cidr = [
    "${cidrsubnet(var.vpc_cidr,8,lookup(var.cidrbyte, "backup1.${var.aws_region}"))}",
    "${cidrsubnet(var.vpc_cidr,8,lookup(var.cidrbyte, "backup2.${var.aws_region}"))}",
    "${cidrsubnet(var.vpc_cidr,8,lookup(var.cidrbyte, "backup3.${var.aws_region}"))}",
  ]
}

resource "aws_security_group" "rdp" {
  name        = "tf_evlab_rdp"
  description = "Used in the terraform"
  vpc_id      = "${var.aws_vpc_id}"

  # HTTP access from anywhere
  ingress {
    from_port   = 3389
    to_port     = 3389
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
  name        = "tf_evlab_domain_member"
  description = "Allow Domain membteer traffic"
  vpc_id      = "${var.aws_vpc_id}"

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
    description = "random"
    from_port   = 49152
    to_port     = 65535
    protocol    = "tcp"
    self        = true
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
