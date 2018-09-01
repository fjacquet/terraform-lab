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
    "${lookup(var.cidr, "back1.${var.aws_region}")}",
    "${lookup(var.cidr, "back2.${var.aws_region}")}",
    "${lookup(var.cidr, "back3.${var.aws_region}")}",
  ]

  aws_sg_ids = [
    "${aws_security_group.rdp.id}",
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
    "${lookup(var.cidr, "back1.${var.aws_region}")}",
    "${lookup(var.cidr, "back2.${var.aws_region}")}",
    "${lookup(var.cidr, "back3.${var.aws_region}")}",
  ]

  aws_sg_ids = [
    "${aws_security_group.rdp.id}",
    "${module.adds.aws_sg_dc_id}",
    "${module.simpana.aws_sg_client_id}",
    "${var.aws_sg_nbuclient_id}",
  ]
}

module "adfs" {
  source = "./adfs"
}

module "dfs" {
  source = "./dfs"
}

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
    "${lookup(var.cidr, "back1.${var.aws_region}")}",
    "${lookup(var.cidr, "back2.${var.aws_region}")}",
    "${lookup(var.cidr, "back3.${var.aws_region}")}",
  ]

  aws_sg_ids = [
    "${aws_security_group.rdp.id}",
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
    "${lookup(var.cidr, "web1.${var.aws_region}")}",
    "${lookup(var.cidr, "web2.${var.aws_region}")}",
    "${lookup(var.cidr, "web3.${var.aws_region}")}",
  ]

  aws_sg_ids = [
    "${aws_security_group.rdp.id}",
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
    "${lookup(var.cidr, "exch1.${var.aws_region}")}",
    "${lookup(var.cidr, "exch2.${var.aws_region}")}",
    "${lookup(var.cidr, "exch3.${var.aws_region}")}",
  ]

  aws_sg_ids = [
    "${aws_security_group.rdp.id}",
    "${module.exch.aws_sg_exch_id}",
    "${module.simpana.aws_sg_client_id}",
    "${var.aws_sg_nbuclient_id}",
  ]
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
    "${lookup(var.cidr, "back1.${var.aws_region}")}",
    "${lookup(var.cidr, "back2.${var.aws_region}")}",
    "${lookup(var.cidr, "back3.${var.aws_region}")}",
  ]

  aws_sg_ids = [
    "${aws_security_group.rdp.id}",
    "${module.ipam.aws_sg_ipam_id}",
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
    "${lookup(var.cidr, "web1.${var.aws_region}")}",
    "${lookup(var.cidr, "web2.${var.aws_region}")}",
    "${lookup(var.cidr, "web3.${var.aws_region}")}",
  ]

  aws_sg_ids = [
    "${aws_security_group.rdp.id}",
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
    "${lookup(var.cidr, "sql1.${var.aws_region}")}",
    "${lookup(var.cidr, "sql2.${var.aws_region}")}",
    "${lookup(var.cidr, "sql3.${var.aws_region}")}",
  ]

  aws_sg_ids = [
    "${aws_security_group.rdp.id}",
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
    "${lookup(var.cidr, "backup1.${var.aws_region}")}",
    "${lookup(var.cidr, "backup2.${var.aws_region}")}",
    "${lookup(var.cidr, "backup3.${var.aws_region}")}",
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
    "${module.simpana.aws_sg_client_id}",
    "${var.aws_sg_nbuclient_id}",
  ]
}

resource "aws_security_group" "rdp" {
  name        = "terraform_evlab_rdp"
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
}
