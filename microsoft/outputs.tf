output "dc_private_ip" {
  description = "DC DNS IPs"
  value       = module.adds.dc_private_ip
}

output "aws_sg_da_id" {
  value = module.da.aws_sg_da_id
}

output "aws_sg_dc_id" {
  value = module.adds.aws_sg_dc_id
}

output "aws_sg_dhcp_id" {
  value = module.dhcp.aws_sg_dhcp_id
}

output "aws_sg_exchange_id" {
  value = module.exchange.aws_sg_exchange_id
}

output "aws_sg_fs_id" {
  value = module.fs.aws_sg_fs_id
}

output "aws_sg_ipam_id" {
  value = module.ipam.aws_sg_ipam_id
}

output "aws_sg_pki-crl_ids" {
  value = module.adcs.aws_sg_pki-crl_ids
}

output "aws_sg_pki-ica_ids" {
  value = module.adcs.aws_sg_pki-ica_ids
}

output "aws_sg_pki-rca_ids" {
  value = module.adcs.aws_sg_pki-rca_ids
}

output "aws_sg_sharepoint_id" {
  value = module.sharepoint.aws_sg_sharepoint_id
}

output "aws_sg_simpana_master_id" {
  value = module.simpana.aws_sg_master_id
}

output "aws_sg_simpana_client_id" {
  value = module.simpana.aws_sg_client_id
}

output "aws_sg_rdp_id" {
  value = aws_security_group.rdp.id
}

output "aws_sg_sql_id" {
  value = module.sql.aws_sg_sql_id
}
