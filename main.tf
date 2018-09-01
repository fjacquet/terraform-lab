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
  cidr       = "${var.cidr}"
  key_name   = "${var.key_name}"
  public_key = "${var.public_key}"
  secret_key = "${var.secret_key}"
}

module "unix" {
  source                  = "./unix"
  aws_amis                = "${var.aws_amis}"
  aws_disks_size          = "${var.aws_disks_size}"
  aws_iip_assumerole_name = "${module.global.aws_iip_assumerole}"
  aws_key_pair_auth_id    = "${module.global.aws_key_pair_auth_id}"
  aws_number              = "${var.aws_number}"
  aws_region              = "${var.aws_region}"
  aws_sg_simpanaclient_id = "${module.microsoft.aws_sg_simpanaclient_id}"
  aws_subnet_back_id      = "${module.global.aws_subnet_back_id}"
  aws_subnet_backup_id    = "${module.global.aws_subnet_backup_id}"
  aws_subnet_web_id       = "${module.global.aws_subnet_web_id}"
  aws_vpc_id              = "${module.global.aws_vpc_id}"
  azs                     = "${var.azs}"
  cidr                    = "${var.cidr}"
}

module "microsoft" {
  source                  = "./microsoft"
  aws_amis                = "${var.aws_amis}"
  aws_iip_assumerole_name = "${module.global.aws_iip_assumerole}"
  aws_key_pair_auth_id    = "${module.global.aws_key_pair_auth_id}"
  aws_number              = "${var.aws_number}"
  aws_region              = "${var.aws_region}"
  aws_sg_nbuclient_id     = "${module.unix.aws_sg_nbuclient_id}"
  aws_subnet_back_id      = "${module.global.aws_subnet_back_id}"
  aws_subnet_backup_id    = "${module.global.aws_subnet_backup_id}"
  aws_subnet_exch_id      = "${module.global.aws_subnet_exch_id}"
  aws_subnet_mgmt_id      = "${module.global.aws_subnet_mgmt_id}"
  aws_subnet_web_id       = "${module.global.aws_subnet_web_id}"
  aws_vpc_id              = "${module.global.aws_vpc_id}"
  azs                     = "${var.azs}"
  cidr                    = "${var.cidr}"
}

resource "aws_vpc_dhcp_options" "dns_resolver" {
  domain_name_servers = [
    "${module.microsoft.dc_private_ip}",
    "10.0.0.2",
    "8.8.8.8",
  ]
}
