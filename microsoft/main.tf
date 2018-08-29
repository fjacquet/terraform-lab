module "adcs" {
  source                  = "./adcs"
  aws_amis                = "${var.aws_amis_win2016}"
  aws_iip_assumerole_name = "${var.aws_iip_assumerole_name}"
  aws_key_pair_auth_id    = "${var.aws_key_pair_auth_id}"
  aws_number_pki_crl      = "${var.aws_number_pki_crl}"
  aws_number_pki_ica      = "${var.aws_number_pki_ica}"
  aws_number_pki_rca      = "${var.aws_number_pki_rca}"
  aws_region              = "${var.aws_region}"
  aws_subnet_id           = "${var.aws_subnet_back_id}"
  aws_vpc_id              = "${var.aws_vpc_id}"
  azs                     = "${var.azs}"
  cidr                    = "${var.cidr_back}"

  aws_sg_ids = [
    "${var.aws_sg_cvltclient_id}",
    "${var.aws_sg_nbuclient_id}",
    "${var.aws_sg_rdp_id}",
    "${module.adcs.aws_sg_pki_crl_id}",
    "${module.adcs.aws_sg_pki_rca_id}",
    "${module.adcs.aws_sg_pki_ica_id}",
  ]
}

module "adds" {
  source                  = "./adds"
  aws_amis                = "${var.aws_amis_win2016}"
  aws_iip_assumerole_name = "${var.aws_iip_assumerole_name}"
  aws_key_pair_auth_id    = "${var.aws_key_pair_auth_id}"
  aws_number              = "${var.aws_number_dc}"
  aws_region              = "${var.aws_region}"
  aws_subnet_id           = "${var.aws_subnet_back_id}"
  aws_vpc_id              = "${var.aws_vpc_id}"
  azs                     = "${var.azs}"
  cidr                    = "${var.cidr_back}"

  aws_sg_ids = [
    "${var.aws_sg_cvltclient_id}",
    "${var.aws_sg_nbuclient_id}",
    "${var.aws_sg_rdp_id}",
    "${module.adds.aws_sg_dc_id}",
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
  aws_amis                = "${var.aws_amis_win2016}"
  aws_iip_assumerole_name = "${var.aws_iip_assumerole_name}"
  aws_key_pair_auth_id    = "${var.aws_key_pair_auth_id}"
  aws_number              = "${var.aws_number_dhcp}"
  aws_region              = "${var.aws_region}"
  aws_subnet_id           = "${var.aws_subnet_back_id}"
  aws_vpc_id              = "${var.aws_vpc_id}"
  azs                     = "${var.azs}"
  cidr                    = "${var.cidr_back}"

  aws_sg_ids = [
    "${var.aws_sg_cvltclient_id}",
    "${var.aws_sg_nbuclient_id}",
    "${var.aws_sg_rdp_id}",
    "${module.dhcp.aws_sg_dhcp_id}",
  ]
}

module "da" {
  source                  = "./da"
  aws_amis                = "${var.aws_amis_win2016}"
  aws_iip_assumerole_name = "${var.aws_iip_assumerole_name}"
  aws_key_pair_auth_id    = "${var.aws_key_pair_auth_id}"
  aws_number              = "${var.aws_number_da}"
  aws_region              = "${var.aws_region}"
  aws_subnet_id           = "${var.aws_subnet_mgmt_id}"
  aws_vpc_id              = "${var.aws_vpc_id}"
  azs                     = "${var.azs}"
  cidr                    = "${var.cidr_web}"

  aws_sg_ids = [
    "${var.aws_sg_rdp_id}",
    "${var.aws_sg_nbuclient_id}",
    "${var.aws_sg_cvltclient_id}",
    "${module.da.aws_sg_da_id}",
  ]
}

module "exch" {
  source                  = "./exch"
  aws_amis                = "${var.aws_amis_win2016}"
  aws_iip_assumerole_name = "${var.aws_iip_assumerole_name}"
  aws_key_pair_auth_id    = "${var.aws_key_pair_auth_id}"
  aws_number              = "${var.aws_number_exch}"
  aws_region              = "${var.aws_region}"
  aws_subnet_id           = "${var.aws_subnet_exch_id}"
  aws_vpc_id              = "${var.aws_vpc_id}"
  azs                     = "${var.azs}"
  cidr                    = "${var.cidr_exch}"

  aws_sg_ids = [
    "${var.aws_sg_cvltclient_id}",
    "${var.aws_sg_nbuclient_id}",
    "${var.aws_sg_rdp_id}",
    "${module.exch.aws_sg_exch_id}",
  ]
}

module "ipam" {
  source                  = "./ipam/"
  aws_amis                = "${var.aws_amis_win2016}"
  aws_iip_assumerole_name = "${var.aws_iip_assumerole_name}"
  aws_key_pair_auth_id    = "${var.aws_key_pair_auth_id}"
  aws_number              = "${var.aws_number_ipam}"
  aws_region              = "${var.aws_region}"
  aws_subnet_id           = "${var.aws_subnet_mgmt_id}"
  aws_vpc_id              = "${var.aws_vpc_id}"
  azs                     = "${var.azs}"
  cidr                    = "${var.cidr_back}"

  aws_sg_ids = [
    "${var.aws_sg_cvltclient_id}",
    "${var.aws_sg_nbuclient_id}",
    "${var.aws_sg_rdp_id}",
    "${module.ipam.aws_sg_ipam_id}",
  ]
}

module "sharepoint" {
  source                  = "./sharepoint"
  aws_amis                = "${var.aws_amis_sharepoint}"
  aws_iip_assumerole_name = "${var.aws_iip_assumerole_name}"
  aws_key_pair_auth_id    = "${var.aws_key_pair_auth_id}"
  aws_number              = "${var.aws_number_sharepoint}"
  aws_region              = "${var.aws_region}"
  aws_subnet_id           = "${var.aws_subnet_web_id}"
  aws_vpc_id              = "${var.aws_vpc_id}"
  azs                     = "${var.azs}"
  cidr                    = "${var.cidr_web}"

  aws_sg_ids = [
    "${var.aws_sg_cvltclient_id}",
    "${var.aws_sg_nbuclient_id}",
    "${var.aws_sg_rdp_id}",
    "${module.sharepoint.aws_sg_sharepoint_id}",
  ]
}

module "sql" {
  source                  = "./sql"
  aws_amis                = "${var.aws_amis_sql}"
  aws_iip_assumerole_name = "${var.aws_iip_assumerole_name}"
  aws_key_pair_auth_id    = "${var.aws_key_pair_auth_id}"
  aws_number              = "${var.aws_number_sql}"
  aws_region              = "${var.aws_region}"
  aws_subnet_id           = "${var.aws_subnet_back_id}"
  aws_vpc_id              = "${var.aws_vpc_id}"
  azs                     = "${var.azs}"
  cidr                    = "${var.cidr_back}"

  aws_sg_ids = [
    "${var.aws_sg_cvltclient_id}",
    "${var.aws_sg_nbuclient_id}",
    "${var.aws_sg_rdp_id}",
    "${module.sql.aws_sg_sql_id}",
  ]
}

module "workfolders" {
  source = "./workfolders"
}

module "simpana" {
  source                  = "./simpana"
  aws_amis                = "${var.aws_amis_win2016}"
  aws_iip_assumerole_name = "${var.aws_iip_assumerole_name}"
  aws_key_pair_auth_id    = "${var.aws_key_pair_auth_id}"
  aws_number              = "${var.aws_number_simpana}"
  aws_region              = "${var.aws_region}"
  aws_subnet_id           = "${var.aws_subnet_mgmt_id}"
  aws_vpc_id              = "${var.aws_vpc_id}"
  azs                     = "${var.azs}"
  cidr                    = "${var.cidr_back}"

  aws_sg_ids = [
    "${var.aws_sg_rdp_id}",
    "${module.simpana.aws_sg_simpana_id}",
  ]
}

module "jumpbox" {
  source                  = "./jumpbox"
  aws_amis                = "${var.aws_amis_jumpbox}"
  aws_iip_assumerole_name = "${var.aws_iip_assumerole_name}"
  aws_key_pair_auth_id    = "${var.aws_key_pair_auth_id}"
  aws_number              = "${var.aws_number_jumpbox}"
  aws_region              = "${var.aws_region}"
  aws_subnet_id           = "${var.aws_subnet_mgmt_id}"
  aws_vpc_id              = "${var.aws_vpc_id}"
  azs                     = "${var.azs}"

  aws_sg_ids = [
    "${var.aws_sg_cvltclient_id}",
    "${var.aws_sg_nbuclient_id}",
    "${var.aws_sg_rdp_id}",
  ]
}
