output "aws_iip_assumerole" {
  value = module.iam.aws_iip_assumerole
}

output "aws_vpc_id" {
  value = module.vpc.aws_vpc_id
}

output "vpc_cidr" {
  value = module.vpc.vpc_cidr
}

output "dns_zone_id" {
  value = module.route53.dns_zone_id
}

output "aws_subnet_back_id" {
  value = module.vpc.aws_subnet_back_id
}

output "aws_subnet_backup_id" {
  value = module.vpc.aws_subnet_backup_id
}

output "aws_subnet_web_id" {
  value = module.vpc.aws_subnet_web_id
}

output "aws_subnet_exchange_id" {
  value = module.vpc.aws_subnet_exchange_id
}

output "aws_subnet_mgmt_id" {
  value = module.vpc.aws_subnet_mgmt_id
}

# output "aws_key_pair_auth_id" {
#   value = module.providers.aws_key_pair_auth_id
# }

# output "cidr" {
#   value = "${var.cidr}"
# }
