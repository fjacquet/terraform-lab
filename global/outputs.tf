output "assumeRole-profile" {
  value = "${module.iam.assumeRole-profile}"
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
