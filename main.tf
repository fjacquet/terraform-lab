provider "aws" {
  access_key = "${var.access_key}"
  region     = "${var.aws_region}"
  secret_key = "${var.secret_key}"
}

module "global" {
  source     = "./global"
  access_key = "${var.access_key}"
  aws_region = "${var.aws_region}"
  azs        = "${var.azs}"
  cidr_back  = "${var.cidr_back}"
  cidr_exch  = "${var.cidr_exch}"
  cidr_gw    = "${var.cidr_gw}"
  cidr_mgmt  = "${var.cidr_mgmt}"
  cidr_vpc   = "${var.cidr_vpc}"
  cidr_vpc   = "${var.cidr_vpc}"
  cidr_web   = "${var.cidr_web}"
  key_name   = "${var.key_name}"
  public_key = "${var.public_key}"
  secret_key = "${var.secret_key}"
}

module "bsd" {
  source               = "./bsd"
  aws_amis             = "${var.aws_amis_bsd}"
  aws_key_pair_auth_id = "${module.global.aws_key_pair_auth_id}"
  aws_number           = "${var.aws_number_bsd}"
  aws_region           = "${var.aws_region}"
  aws_subnet_id        = "${module.global.aws_subnet_mgmt_id}"
  azs                  = "${var.azs}"

  aws_sg_ids = [
    "${aws_security_group.ssh.id}",
    "${aws_security_group.nbuclient.id}",
    "${aws_security_group.cvltclient.id}",
  ]
}

module "linux" {
  source                  = "./linux"
  aws_amis_guacamole      = "${var.aws_amis_guacamole}"
  aws_amis_nbu            = "${var.aws_amis_nbu}"
  aws_amis_oracle         = "${var.aws_amis_oracle}"
  aws_iip_assumerole_name = "${module.global.aws_iip_assumerole}"
  aws_key_pair_auth_id    = "${module.global.aws_key_pair_auth_id}"
  aws_number_guacamole    = "${var.aws_number_guacamole}"
  aws_number_nbumaster    = "${var.aws_number_nbumaster}"
  aws_number_oracle       = "${var.aws_number_oracle}"
  aws_region              = "${var.aws_region}"
  aws_sg_cvltclient_id    = "${aws_security_group.cvltclient.id}"
  aws_sg_nbuclient_id     = "${aws_security_group.nbuclient.id}"
  aws_sg_ssh_id           = "${aws_security_group.ssh.id}"
  aws_size_nbu_backups    = "${var.aws_size_nbu_backups}"
  aws_size_nbu_openv      = "${var.aws_size_nbu_openv}"
  aws_subnet_back_id      = "${module.global.aws_subnet_back_id}"
  aws_subnet_web_id       = "${module.global.aws_subnet_web_id}"
  aws_vpc_id              = "${module.global.aws_vpc_id}"
  azs                     = "${var.azs}"
  cidr_back               = "${module.global.cidr_back}"
  cidr_exch               = "${module.global.cidr_exch}"
  cidr_mgmt               = "${module.global.cidr_mgmt}"
  cidr_web                = "${module.global.cidr_web}"
}

module "microsoft" {
  source = "./microsoft"

  aws_amis_jumpbox        = "${var.aws_amis_win2016}"
  aws_amis_sharepoint     = "${var.aws_amis_sharepoint}"
  aws_amis_sql            = "${var.aws_amis_sql}"
  aws_amis_win2016        = "${var.aws_amis_win2016}"
  aws_iip_assumerole_name = "${module.global.aws_iip_assumerole}"
  aws_key_pair_auth_id    = "${module.global.aws_key_pair_auth_id}"
  aws_number_da           = "${var.aws_number_da}"
  aws_number_dc           = "${var.aws_number_dc}"
  aws_number_dhcp         = "${var.aws_number_dhcp}"
  aws_number_exch         = "${var.aws_number_exch}"
  aws_number_ipam         = "${var.aws_number_ipam}"
  aws_number_jumpbox      = "${var.aws_number_jumpbox}"
  aws_number_pki_crl      = "${var.aws_number_pki_crl}"
  aws_number_pki_ica      = "${var.aws_number_pki_ica}"
  aws_number_pki_rca      = "${var.aws_number_pki_rca}"
  aws_number_sharepoint   = "${var.aws_number_sharepoint}"
  aws_number_simpana      = "${var.aws_number_simpana}"
  aws_number_sql          = "${var.aws_number_sql}"
  aws_region              = "${var.aws_region}"
  aws_sg_cvltclient_id    = "${aws_security_group.cvltclient.id}"
  aws_sg_nbuclient_id     = "${aws_security_group.nbuclient.id}"
  aws_sg_rdp_id           = "${aws_security_group.rdp.id}"
  aws_subnet_back_id      = "${module.global.aws_subnet_back_id}"
  aws_subnet_exch_id      = "${module.global.aws_subnet_exch_id}"
  aws_subnet_mgmt_id      = "${module.global.aws_subnet_mgmt_id}"
  aws_subnet_web_id       = "${module.global.aws_subnet_web_id}"
  aws_vpc_id              = "${module.global.aws_vpc_id}"
  azs                     = "${var.azs}"
  cidr_back               = "${module.global.cidr_back}"
  cidr_exch               = "${module.global.cidr_exch}"
  cidr_mgmt               = "${module.global.cidr_mgmt}"
  cidr_web                = "${module.global.cidr_web}"
}

resource "aws_vpc_dhcp_options" "dns_resolver" {
  domain_name_servers = [
    "${module.microsoft.dc_private_ip}",
    "10.0.0.2",
    "8.8.8.8",
  ]
}
