# Amazon access
provider "aws" {
  access_key = "${var.access_key}"
  region     = "${var.aws_region}"
  secret_key = "${var.secret_key}"
}

resource "aws_key_pair" "auth" {
  key_name   = "${var.key_name}"
  public_key = "${var.public_key}"
}

module "global" {
  source     = "./global"
  azs        = "${var.azs}"
  access_key = "${var.access_key}"
  aws_region = "${var.aws_region}"
  secret_key = "${var.secret_key}"
  cidr_vpc   = "${var.cidr_vpc}"
  cidr_vpc   = "${var.cidr_vpc}"
  cidr_back  = "${var.cidr_back}"
  cidr_exch  = "${var.cidr_exch}"
  cidr_gw    = "${var.cidr_gw}"
  cidr_mgmt  = "${var.cidr_mgmt}"
  cidr_web   = "${var.cidr_web}"
}

module "bsd" {
  source               = "./bsd"
  aws_amis             = "${var.aws_amis_bsd}"
  aws_key_pair_auth_id = "${aws_key_pair.auth.id}"
  aws_number           = "${var.aws_number_bsd}"
  aws_region           = "${var.aws_region}"
  aws_subnet_id        = "${module.global.aws_subnet_mgmt_id}"
  azs                  = "${var.azs}"

  aws_sg_id = [
    "${aws_security_group.ssh.id}",
    "${aws_security_group.nbuclient.id}",
    "${aws_security_group.cvltclient.id}",
  ]
}

module "linux" {
  source                 = "./linux"
  aws_amis_guacamole     = "${var.aws_amis_guacamole}"
  aws_amis_nbu           = "${var.aws_amis_nbu}"
  aws_amis_oracle        = "${var.aws_amis_oracle}"
  aws_ip_assumeRole_name = "${module.global.assumeRole-profile}"
  aws_key_pair_auth_id   = "${aws_key_pair.auth.id}"
  aws_number_guacamole   = "${var.aws_number_guacamole}"
  aws_number_nbumaster   = "${var.aws_number_nbumaster}"
  aws_number_oracle      = "${var.aws_number_oracle}"
  aws_region             = "${var.aws_region}"
  aws_sg_guacamole_id    = ["${aws_security_group.cvltclient.id}", "${aws_security_group.nbuclient.id}", "${aws_security_group.ssh.id}"]
  aws_sg_oracle_id       = ["${aws_security_group.cvltclient.id}", "${aws_security_group.nbuclient.id}", "${aws_security_group.ssh.id}", "${aws_security_group.oracle.id}"]
  aws_size_nbu_backups   = "${var.aws_size_nbu_backups}"
  aws_size_nbu_openv     = "${var.aws_size_nbu_openv}"
  aws_subnet_id          = "${module.global.aws_subnet_mgmt_id}"
  aws_vpc_id             = "${module.global.aws_vpc_id}"
  azs                    = "${var.azs}"
}

module "microsoft" {
  source                 = "./microsoft"
  aws_amis_sharepoint    = "${var.aws_amis_sharepoint}"
  aws_amis_sql2016       = "${var.aws_amis_sql2016}"
  aws_amis_win2016       = "${var.aws_amis_win2016}"
  aws_ip_assumeRole_name = "${module.global.assumeRole-profile}"
  cidr_back              = "${module.global.cidr_back}"
  aws_key_pair_auth_id   = "${aws_key_pair.auth.id}"
  aws_number_da          = "${var.aws_number_da}"
  aws_number_dc          = "${var.aws_number_dc}"
  aws_number_dhcp        = "${var.aws_number_dhcp}"
  aws_number_exch        = "${var.aws_number_exch}"
  aws_number_ipam        = "${var.aws_number_ipam}"
  aws_number_jumpbox     = "${var.aws_number_jumpbox}"
  aws_number_pki_crl     = "${var.aws_number_pki_crl}"
  aws_number_pki_ica     = "${var.aws_number_pki_ica}"
  aws_number_pki_rca     = "${var.aws_number_pki_rca}"
  aws_number_simpana     = "${var.aws_number_simpana}"
  aws_number_sharepoint  = "${var.aws_number_sharepoint}"
  aws_number_sql         = "${var.aws_number_sql}"
  aws_region             = "${var.aws_region}"
  aws_sg_cvltclient_id   = "${aws_security_group.cvltclient.id}"
  aws_sg_nbuclient_id    = "${aws_security_group.nbuclient.id}"
  aws_sg_rdp_id          = "${aws_security_group.rdp.id}"
  aws_subnet_back_id     = "${module.global.aws_subnet_back_id}"
  aws_subnet_exch_id     = "${module.global.aws_subnet_exch_id}"
  aws_subnet_mgmt_id     = "${module.global.aws_subnet_mgmt_id}"
  aws_subnet_web_id      = "${module.global.aws_subnet_web_id}"
  aws_vpc_id             = "${module.global.aws_vpc_id}"
  azs                    = "${var.azs}"
}

# module "mgmt" {
#   source                 = "./mgmt"

#   aws_ip_assumeRole_name = "${module.global.assumeRole-profile}"
#   aws_key_pair_auth_id   = "${aws_key_pair.auth.id}"
#   aws_mgmt_amis          = "${var.aws_mgmt_amis}"
#   aws_mgmt_number        = "${var.aws_mgmt_number}"
#   aws_region             = "${var.aws_region}"
#   aws_sg_cvltclient_id   = "${aws_security_group.cvltclient.id}"

#   aws_sg_nbuclient_id    = "${aws_security_group.nbuclient.id}"
#   aws_sg_rdp_id          = "${aws_security_group.rdp.id}"
#   aws_sg_ssh_id          = "${aws_security_group.ssh.id}"
#   aws_subnet_id          = "${module.global.aws_subnet_mgmt_id}"
#   azs                    = "${var.azs}"
# }

# module "backup" {
#   source                 = "./backup"
#   aws_ip_assumeRole_name = "${module.global.assumeRole-profile}"
#   aws_key_pair_auth_id   = "${aws_key_pair.auth.id}"
#   aws_nbu_amis           = "${var.aws_nbu_amis}"
#   aws_nbu_backups_size   = "${var.aws_nbu_backups_size}"
#   aws_nbu_backups_size   = "${var.aws_nbu_backups_size}"
#   aws_nbu_openv_size     = "${var.aws_nbu_openv_size}"
#   aws_nbumaster_number   = "${var.aws_nbumaster_number}"
#   aws_region             = "${var.aws_region}"
#   aws_sg_nbuclient_id    = "${aws_security_group.nbuclient.id}"
#   aws_sg_nbumaster_id    = "${aws_security_group.nbumaster.id}"
#   aws_sg_rdp_id          = "${aws_security_group.rdp.id}"
#   aws_sg_simpana_id      = "${aws_security_group.simpana.id}"
#   aws_sg_ssh_id          = "${aws_security_group.ssh.id}"
#   aws_simpana_number     = "${var.aws_simpana_number}"
#   aws_subnet_mgmt_id     = "${module.global.aws_subnet_mgmt_id}"
#   aws_win2016_amis       = "${var.aws_win2016_amis}"
#   azs                    = "${var.azs}"
# }

resource "aws_vpc_dhcp_options" "dns_resolver" {
  domain_name_servers = [
    "${module.microsoft.dc_private_ip}",
    "10.0.0.2",
    "8.8.8.8",
  ]
}
