output "dc_private_ip" {
  description = "description"
  value       = "${module.adds.dc_private_ip}"
}

output "aws_sg_da_id" {
  value = "${module.da.aws_sg_da_id}"
}

output "aws_sg_dc_id" {
  value = "${module.adds.aws_sg_dc_id}"
}

output "aws_sg_dhcp_id" {
  value = "${module.dhcp.aws_sg_dhcp_id}"
}

output "aws_sg_exch_id" {
  value = "${module.exch.aws_sg_exch_id}"
}

output "aws_sg_ipam_id" {
  value = "${module.ipam.aws_sg_ipam_id}"
}

output "aws_sg_pki_crl_id" {
  value = "${module.adcs.aws_sg_pki_crl_id}"
}

output "aws_sg_pki_ica_id" {
  value = "${module.adcs.aws_sg_pki_ica_id}"
}

output "aws_sg_pki_rca_id" {
  value = "${module.adcs.aws_sg_pki_rca_id}"
}

output "aws_sg_sharepoint_id" {
  value = "${module.sharepoint.aws_sg_sharepoint_id}"
}

output "aws_sg_simpana_id" {
  value = "${module.simpana.aws_sg_simpana_id}"
}

output "aws_sg_sql_id" {
  value = "${module.sql.aws_sg_sql_id}"
}
