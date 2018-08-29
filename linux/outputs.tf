output "aws_sg_oracle_id" {
  value = "${module.oracle.aws_sg_oracle_id}"
}

output "aws_sg_nbumaster_id" {
  value = "${module.nbu.aws_sg_nbumaster_id}"
}

output "aws_sg_guacamole_id" {
  value = "${module.guacamole.aws_sg_guacamole_id}"
}
