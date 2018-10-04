module "providers" {
  source     = "./providers/"
  access_key = "${var.access_key}"
  aws_region = "${var.aws_region}"
  secret_key = "${var.secret_key}"
  key_name   = "${var.key_name}"
  public_key = "${var.public_key}"
}

module "iam" {
  source     = "./iam/"
  aws_vpc_id = "${module.vpc.aws_vpc_id}"
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
  source = "./vpc"
  azs    = "${var.azs}"

  # cidr       = "${var.cidr}"
  cidrbyte   = "${var.cidrbyte}"
  aws_region = "${var.aws_region}"
  dhcpops    = "${var.dhcpops}"

  cidrbyte_back = [
    "${lookup(var.cidrbyte, "back1.${var.aws_region}")}",
    "${lookup(var.cidrbyte, "back2.${var.aws_region}")}",
    "${lookup(var.cidrbyte, "back3.${var.aws_region}")}",
  ]

  cidrbyte_backup = [
    "${lookup(var.cidrbyte, "backup1.${var.aws_region}")}",
    "${lookup(var.cidrbyte, "backup2.${var.aws_region}")}",
    "${lookup(var.cidrbyte, "backup3.${var.aws_region}")}",
  ]

  cidrbyte_exchange = [
    "${lookup(var.cidrbyte, "exchange1.${var.aws_region}")}",
    "${lookup(var.cidrbyte, "exchange2.${var.aws_region}")}",
    "${lookup(var.cidrbyte, "exchange3.${var.aws_region}")}",
  ]

  cidrbyte_gw = [
    "${lookup(var.cidrbyte, "gw1.${var.aws_region}")}",
    "${lookup(var.cidrbyte, "gw2.${var.aws_region}")}",
    "${lookup(var.cidrbyte, "gw3.${var.aws_region}")}",
  ]

  cidrbyte_mgmt = [
    "${lookup(var.cidrbyte, "mgmt1.${var.aws_region}")}",
    "${lookup(var.cidrbyte, "mgmt2.${var.aws_region}")}",
    "${lookup(var.cidrbyte, "mgmt3.${var.aws_region}")}",
  ]

  cidrbyte_sql = [
    "${lookup(var.cidrbyte, "sql1.${var.aws_region}")}",
    "${lookup(var.cidrbyte, "sql2.${var.aws_region}")}",
    "${lookup(var.cidrbyte, "sql3.${var.aws_region}")}",
  ]

  cidrbyte_web = [
    "${lookup(var.cidrbyte, "web1.${var.aws_region}")}",
    "${lookup(var.cidrbyte, "web2.${var.aws_region}")}",
    "${lookup(var.cidrbyte, "web3.${var.aws_region}")}",
  ]
}

module "dynamodb" {
  source = "./dynamodb"
}
