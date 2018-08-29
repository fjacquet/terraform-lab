output "aws_iip_assumerole" {
  value = "${module.iam.aws_iip_assumerole}"
}

output "aws_vpc_id" {
  value = "${module.vpc.aws_vpc_id}"
}

output "aws_subnet_back_id" {
  value = "${module.vpc.aws_subnet_back_id}"
}

output "aws_subnet_web_id" {
  value = "${module.vpc.aws_subnet_web_id}"
}

output "aws_subnet_exch_id" {
  value = "${module.vpc.aws_subnet_exch_id}"
}

output "aws_subnet_mgmt_id" {
  value = "${module.vpc.aws_subnet_mgmt_id}"
}

output "aws_key_pair_auth_id" {
  value = "${module.providers.aws_key_pair_auth_id}"
}

output "cidr_back" {
  value = "${var.cidr_back}"
}

output "cidr_exch" {
  value = "${var.cidr_exch}"
}

output "cidr_gw" {
  value = "${var.cidr_gw}"
}

output "cidr_mgmt" {
  value = "${var.cidr_mgmt}"
}

output "cidr_web" {
  value = "${var.cidr_web}"
}

