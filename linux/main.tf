module "oracle" {
  source                 = "./oracle"
  aws_amis               = "${var.aws_amis_oracle}"
  aws_ip_assumeRole_name = "${var.aws_ip_assumeRole_name}"
  aws_key_pair_auth_id   = "${var.aws_key_pair_auth_id}"
  aws_number             = "${var.aws_number_oracle}"
  aws_region             = "${var.aws_region}"
  aws_subnet_id          = "${var.aws_subnet_id}"
  aws_vpc_id             = "${var.aws_vpc_id}"
  azs                    = "${var.azs}"
  cidr                   = "${var.cidr_back}"

  aws_sg_id = [
    "${var.aws_sg_cvltclient_id}",
    "${var.aws_sg_nbuclient_id}",
    "${var.aws_sg_oracle_id}",
    "${var.aws_sg_ssh_id}",
  ]
}

module "guacamole" {
  source                 = "./guacamole"
  aws_amis               = "${var.aws_amis_guacamole}"
  aws_ip_assumeRole_name = "${var.aws_ip_assumeRole_name}"
  aws_key_pair_auth_id   = "${var.aws_key_pair_auth_id}"
  aws_number             = "${var.aws_number_guacamole}"
  aws_region             = "${var.aws_region}"
  aws_subnet_id          = "${var.aws_subnet_id}"
  aws_vpc_id             = "${var.aws_vpc_id}"
  azs                    = "${var.azs}"

  aws_sg_id = [
    "${var.aws_sg_ssh_id}",
  ]
}

module "nbu" {
  source                 = "./nbu"
  aws_amis               = "${var.aws_amis_nbu}"
  aws_ip_assumeRole_name = "${var.aws_ip_assumeRole_name}"
  aws_key_pair_auth_id   = "${var.aws_key_pair_auth_id}"
  aws_number             = "${var.aws_number_nbumaster}"
  aws_region             = "${var.aws_region}"
  aws_size_nbu_backups   = "${var.aws_size_nbu_backups}"
  aws_size_nbu_openv     = "${var.aws_size_nbu_openv}"
  aws_subnet_id          = "${var.aws_subnet_mgmt_id}"
  aws_vpc_id             = "${var.aws_vpc_id}"
  azs                    = "${var.azs}"
  cidr                   = "${var.cidr_back}"

  aws_sg_id = [
    "${var.aws_sg_nbuclient_id}",
    "${var.aws_sg_nbumaster_id}",
    "${var.aws_sg_ssh_id}",
  ]
}
