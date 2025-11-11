output "aws_sg_oracle_id" {
  value = module.oracle.aws_sg_oracle_id
}

output "aws_sg_nbumaster_ids" {
  value = module.nbu.aws_sg_master_ids
}

output "aws_sg_nbuclient_ids" {
  value = module.nbu.aws_sg_client_ids
}

output "aws_sg_guacamole_id" {
  value = module.guacamole.aws_sg_guacamole_id
}

output "aws_sg_ssh_id" {
  value = aws_security_group.ssh.id
}
