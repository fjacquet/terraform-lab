# module "providers" {
#   source     = "./providers/"
#   access_key = var.access_key
#   aws_region = var.aws_region
#   secret_key = var.secret_key
#   key_name   = var.key_name
#   public_key = var.public_key
# }

module "iam" {
  source     = "./iam/"
  aws_vpc_id = module.vpc.aws_vpc_id
}

module "route53" {
  source        = "./route53"
  aws_vpc_id    = module.vpc.aws_vpc_id
  dns_suffix    = var.dns_suffix
  public_dns_id = var.public_dns_id
}

# module "s3" {
#   source = "./s3"
# }

module "demand" {
  source = "./demand"
}

module "vpc" {
  source = "./vpc"
  azs    = var.azs

  # cidr       = "${var.cidr}"
  cidrbyte   = var.cidrbyte
  aws_region = var.aws_region
  aws_number = var.aws_number
  # dhcpops    = var.dhcpops

  cidrbyte_back = [
    var.cidrbyte["back1.${var.aws_region}"],
    var.cidrbyte["back2.${var.aws_region}"],
    var.cidrbyte["back3.${var.aws_region}"],
  ]

  cidrbyte_backup = [
    var.cidrbyte["backup1.${var.aws_region}"],
    var.cidrbyte["backup2.${var.aws_region}"],
    var.cidrbyte["backup3.${var.aws_region}"],
  ]

  cidrbyte_exchange = [
    var.cidrbyte["exchange1.${var.aws_region}"],
    var.cidrbyte["exchange2.${var.aws_region}"],
    var.cidrbyte["exchange3.${var.aws_region}"],
  ]

  cidrbyte_gw = [
    var.cidrbyte["gw1.${var.aws_region}"],
    var.cidrbyte["gw2.${var.aws_region}"],
    var.cidrbyte["gw3.${var.aws_region}"],
  ]

  cidrbyte_mgmt = [
    var.cidrbyte["mgmt1.${var.aws_region}"],
    var.cidrbyte["mgmt2.${var.aws_region}"],
    var.cidrbyte["mgmt3.${var.aws_region}"],
  ]

  cidrbyte_sql = [
    var.cidrbyte["sql1.${var.aws_region}"],
    var.cidrbyte["sql2.${var.aws_region}"],
    var.cidrbyte["sql3.${var.aws_region}"],
  ]

  cidrbyte_web = [
    var.cidrbyte["web1.${var.aws_region}"],
    var.cidrbyte["web2.${var.aws_region}"],
    var.cidrbyte["web3.${var.aws_region}"],
  ]
}

module "dynamodb" {
  source = "./dynamodb"
}
