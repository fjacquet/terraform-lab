module "guacamole" {
  source                  = "./guacamole"
  aws_amis                = "${var.aws_amis_guacamole}"
  aws_iip_assumerole_name = "${var.aws_iip_assumerole_name}"
  aws_key_pair_auth_id    = "${var.aws_key_pair_auth_id}"
  aws_number              = "${var.aws_number_guacamole}"
  aws_region              = "${var.aws_region}"
  aws_subnet_id           = "${var.aws_subnet_web_id}"
  aws_vpc_id              = "${var.aws_vpc_id}"
  azs                     = "${var.azs}"

  aws_sg_ids = [
    "${var.aws_sg_ssh_id}",
    "${module.guacamole.aws_sg_guacamole_id}",
  ]
}

module "nbu" {
  source                  = "./nbu"
  aws_amis                = "${var.aws_amis_nbu}"
  aws_iip_assumerole_name = "${var.aws_iip_assumerole_name}"
  aws_key_pair_auth_id    = "${var.aws_key_pair_auth_id}"
  aws_number              = "${var.aws_number_nbumaster}"
  aws_region              = "${var.aws_region}"
  aws_size_nbu_backups    = "${var.aws_size_nbu_backups}"
  aws_size_nbu_openv      = "${var.aws_size_nbu_openv}"
  aws_subnet_id           = "${var.aws_subnet_back_id}"
  aws_vpc_id              = "${var.aws_vpc_id}"
  azs                     = "${var.azs}"
  cidr                    = "${var.cidr_back}"

  aws_sg_ids = [
    "${var.aws_sg_nbuclient_id}",
    "${module.nbu.aws_sg_nbumaster_id}",
    "${var.aws_sg_ssh_id}",
  ]
}

module "oracle" {
  source                  = "./oracle"
  aws_amis                = "${var.aws_amis_oracle}"
  aws_iip_assumerole_name = "${var.aws_iip_assumerole_name}"
  aws_key_pair_auth_id    = "${var.aws_key_pair_auth_id}"
  aws_number              = "${var.aws_number_oracle}"
  aws_region              = "${var.aws_region}"
  aws_subnet_id           = "${var.aws_subnet_back_id}"
  aws_vpc_id              = "${var.aws_vpc_id}"
  azs                     = "${var.azs}"
  cidr                    = "${var.cidr_back}"

  aws_sg_ids = [
    "${module.oracle.aws_sg_oracle_id}",
    "${var.aws_sg_cvltclient_id}",
    "${var.aws_sg_nbuclient_id}",
    "${var.aws_sg_ssh_id}",
  ]
}
