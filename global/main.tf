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

  cidrbyte_exch = [
    "${lookup(var.cidrbyte, "exch1.${var.aws_region}")}",
    "${lookup(var.cidrbyte, "exch2.${var.aws_region}")}",
    "${lookup(var.cidrbyte, "exch3.${var.aws_region}")}",
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

  # subnet_back = [
  #   "${lookup(var.cidr, "back1.${var.aws_region}")}",
  #   "${lookup(var.cidr, "back2.${var.aws_region}")}",
  #   "${lookup(var.cidr, "back3.${var.aws_region}")}",
  # ]

  # subnet_backup = [
  #   "${lookup(var.cidr, "backup1.${var.aws_region}")}",
  #   "${lookup(var.cidr, "backup2.${var.aws_region}")}",
  #   "${lookup(var.cidr, "backup3.${var.aws_region}")}",
  # ]

  # subnet_exch = [
  #   "${lookup(var.cidr, "exch1.${var.aws_region}")}",
  #   "${lookup(var.cidr, "exch2.${var.aws_region}")}",
  #   "${lookup(var.cidr, "exch3.${var.aws_region}")}",
  # ]

  # subnet_gw = [
  #   "${lookup(var.cidr, "gw1.${var.aws_region}")}",
  #   "${lookup(var.cidr, "gw2.${var.aws_region}")}",
  #   "${lookup(var.cidr, "gw3.${var.aws_region}")}",
  # ]

  # subnet_mgmt = [
  #   "${lookup(var.cidr, "mgmt1.${var.aws_region}")}",
  #   "${lookup(var.cidr, "mgmt2.${var.aws_region}")}",
  #   "${lookup(var.cidr, "mgmt3.${var.aws_region}")}",
  # ]

  # subnet_sql = [
  #   "${lookup(var.cidr, "sql1.${var.aws_region}")}",
  #   "${lookup(var.cidr, "sql2.${var.aws_region}")}",
  #   "${lookup(var.cidr, "sql3.${var.aws_region}")}",
  # ]

  # subnet_web = [
  #   "${lookup(var.cidr, "web1.${var.aws_region}")}",
  #   "${lookup(var.cidr, "web2.${var.aws_region}")}",
  #   "${lookup(var.cidr, "web3.${var.aws_region}")}",
  # ]
}

module "dynamodb" {
  source = "./dynamodb"
}
