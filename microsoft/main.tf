module "adcs" {
  source                 = "./adcs"
  aws_amis               = "${var.aws_amis_win2016}"
  aws_ip_assumeRole_name = "${var.aws_ip_assumeRole_name}"
  aws_key_pair_auth_id   = "${var.aws_key_pair_auth_id}"
  aws_number_pki_crl     = "${var.aws_number_pki_crl}"
  aws_number_pki_ica     = "${var.aws_number_pki_ica}"
  aws_number_pki_rca     = "${var.aws_number_pki_rca}"
  aws_region             = "${var.aws_region}"
  aws_subnet_id          = "${var.aws_subnet_back_id}"
  azs                    = "${var.azs}"
  cidr                   = "${var.cidr_back}"

  aws_sg_id = [
    "${var.aws_sg_cvltclient_id}",
    "${var.aws_sg_nbuclient_id}",
    "${var.aws_sg_rdp_id}",
  ]
}

module "adds" {
  source                 = "./adds"
  aws_amis               = "${var.aws_amis_win2016}"
  aws_ip_assumeRole_name = "${var.aws_ip_assumeRole_name}"
  aws_key_pair_auth_id   = "${var.aws_key_pair_auth_id}"
  aws_number             = "${var.aws_number_dc}"
  aws_region             = "${var.aws_region}"
  aws_subnet_id          = "${var.aws_subnet_back_id}"
  aws_vpc_id             = "${var.aws_vpc_id}"
  azs                    = "${var.azs}"
  cidr                   = "${var.cidr_back}"

  aws_sg_id = [
    "${var.aws_sg_cvltclient_id}",
    "${var.aws_sg_nbuclient_id}",
    "${var.aws_sg_rdp_id}",
  ]
}

module "adfs" {
  source = "./adfs"
}

module "dfs" {
  source = "./dfs"
}

module "dhcp" {
  source                 = "./dhcp"
  aws_amis               = "${var.aws_amis_win2016}"
  aws_ip_assumeRole_name = "${var.aws_ip_assumeRole_name}"
  aws_key_pair_auth_id   = "${var.aws_key_pair_auth_id}"
  aws_number             = "${var.aws_number_dhcp}"
  aws_region             = "${var.aws_region}"
  aws_subnet_id          = "${var.aws_subnet_back_id}"
  azs                    = "${var.azs}"

  aws_sg_id = [
    "${var.aws_sg_cvltclient_id}",
    "${var.aws_sg_nbuclient_id}",
    "${var.aws_sg_rdp_id}",
  ]
}

module "directaccess" {
  source                 = "./directaccess"
  aws_amis               = "${var.aws_amis_win2016}"
  aws_ip_assumeRole_name = "${var.aws_ip_assumeRole_name}"
  aws_key_pair_auth_id   = "${var.aws_key_pair_auth_id}"
  aws_number             = "${var.aws_number_da}"
  aws_region             = "${var.aws_region}"
  aws_subnet_id          = "${var.aws_subnet_mgmt_id}"
  azs                    = "${var.azs}"

  aws_sg_id = ["${var.aws_sg_rdp_id}",
    "${var.aws_sg_nbuclient_id}",
    "${var.aws_sg_cvltclient_id}",
  ]
}

module "exchange" {
  source                 = "./exchange"
  aws_amis               = "${var.aws_amis_win2016}"
  aws_ip_assumeRole_name = "${var.aws_ip_assumeRole_name}"
  aws_key_pair_auth_id   = "${var.aws_key_pair_auth_id}"
  aws_number             = "${var.aws_number_exch}"
  aws_region             = "${var.aws_region}"
  aws_subnet_id          = "${var.aws_subnet_exch_id}"
  azs                    = "${var.azs}"

  aws_sg_id = [
    "${var.aws_sg_cvltclient_id}",
    "${var.aws_sg_nbuclient_id}",
    "${var.aws_sg_rdp_id}",
  ]
}

module "ipam" {
  source                 = "./ipam/"
  aws_amis               = "${var.aws_amis_win2016}"
  aws_ip_assumeRole_name = "${var.aws_ip_assumeRole_name}"
  aws_key_pair_auth_id   = "${var.aws_key_pair_auth_id}"
  aws_number             = "${var.aws_number_ipam}"
  aws_region             = "${var.aws_region}"
  aws_subnet_id          = "${var.aws_subnet_mgmt_id}"
  azs                    = "${var.azs}"
  cidr                   = "${var.cidr_back}"

  aws_sg_id = [
    "${var.aws_sg_cvltclient_id}",
    "${var.aws_sg_nbuclient_id}",
    "${var.aws_sg_rdp_id}",
  ]
}

module "sharepoint" {
  source                 = "./sharepoint"
  aws_amis               = "${var.aws_amis_sharepoint}"
  aws_ip_assumeRole_name = "${var.aws_ip_assumeRole_name}"
  aws_key_pair_auth_id   = "${var.aws_key_pair_auth_id}"
  aws_number             = "${var.aws_number_sharepoint}"
  aws_region             = "${var.aws_region}"
  aws_subnet_id          = "${var.aws_subnet_web_id}"
  aws_vpc_id             = "${var.aws_vpc_id}"
  azs                    = "${var.azs}"

  aws_sg_id = [
    "${var.aws_sg_cvltclient_id}",
    "${var.aws_sg_nbuclient_id}",
    "${var.aws_sg_rdp_id}",
  ]
}

module "sqlserver" {
  source                 = "./sqlserver"
  aws_amis               = "${var.aws_amis_sql2016}"
  aws_ip_assumeRole_name = "${var.aws_ip_assumeRole_name}"
  aws_key_pair_auth_id   = "${var.aws_key_pair_auth_id}"
  aws_number             = "${var.aws_number_sql}"
  aws_region             = "${var.aws_region}"
  aws_subnet_id          = "${var.aws_subnet_back_id}"
  azs                    = "${var.azs}"

  aws_sg_id = [
    "${var.aws_sg_cvltclient_id}",
    "${var.aws_sg_nbuclient_id}",
    "${var.aws_sg_rdp_id}",
  ]
}

module "workfolders" {
  source = "./workfolders"
}

module "commvault" {
  source                 = "./commvault"
  aws_amis               = "${var.aws_amis_win2016}"
  aws_ip_assumeRole_name = "${var.aws_ip_assumeRole_name}"
  aws_key_pair_auth_id   = "${var.aws_key_pair_auth_id}"
  aws_number             = "${var.aws_number_simpana}"
  aws_region             = "${var.aws_region}"
  aws_subnet_id          = "${var.aws_subnet_mgmt_id}"
  aws_vpc_id             = "${var.aws_vpc_id}"
  azs                    = "${var.azs}"
  cidr                   = "${var.cidr_back}"

  aws_sg_id = [
    "${var.aws_sg_rdp_id}",
  ]
}

module "jumpbox" {
  source                 = "./jumpbox"
  aws_amis               = "${var.aws_amis_jumpbox}"
  aws_ip_assumeRole_name = "${var.aws_ip_assumeRole_name}"
  aws_key_pair_auth_id   = "${var.aws_key_pair_auth_id}"
  aws_number             = "${var.aws_number_jumpbox}"
  aws_region             = "${var.aws_region}"
  aws_subnet_id          = "${var.aws_subnet_id}"
  azs                    = "${var.azs}"

  aws_sg_id = [
    "${var.aws_sg_cvltclient_id}",
    "${var.aws_sg_nbuclient_id}",
    "${var.aws_sg_rdp_id}",
  ]
}
