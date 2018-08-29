module "providers" {
  source     = "./providers/"
  access_key = "${var.access_key}"
  aws_region = "${var.aws_region}"
  secret_key = "${var.secret_key}"
  key_name   = "${var.key_name}"
  public_key = "${var.public_key}"
}

module "iam" {
  source = "./iam/"
}

module "route53" {
  source     = "./route53"
  aws_vpc_id = "${module.vpc.aws_vpc_id}"
}

module "s3" {
  source = "./s3"
}

module "demand" {
  source = "./demand"
}

module "vpc" {
  source     = "./vpc"
  access_key = "${var.access_key}"
  azs        = "${var.azs}"
  secret_key = "${var.secret_key}"
  aws_region = "${var.aws_region}"
  cidr_vpc   = "${var.cidr_vpc}"
  cidr_back  = "${var.cidr_back}"
  cidr_exch  = "${var.cidr_exch}"
  cidr_gw    = "${var.cidr_gw}"
  cidr_mgmt  = "${var.cidr_mgmt}"
  cidr_web   = "${var.cidr_web}"
}

module "dynamodb" {
  source = "./dynamodb"
}
