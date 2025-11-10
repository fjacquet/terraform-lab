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

module "demand" {
  source = "./demand"
}

module "vpc" {
  source     = "./vpc"
  azs        = var.azs
  cidrbyte   = var.cidrbyte
  aws_region = var.aws_region
  aws_number = var.aws_number

  # Dynamically generate cidrbyte arrays using for expressions
  # This eliminates hardcoded arrays and makes the code more maintainable
  cidrbyte_back = [
    for i in range(1, 4) : var.cidrbyte["back${i}.${var.aws_region}"]
  ]

  cidrbyte_backup = [
    for i in range(1, 4) : var.cidrbyte["backup${i}.${var.aws_region}"]
  ]

  cidrbyte_exchange = [
    for i in range(1, 4) : var.cidrbyte["exchange${i}.${var.aws_region}"]
  ]

  cidrbyte_gw = [
    for i in range(1, 4) : var.cidrbyte["gw${i}.${var.aws_region}"]
  ]

  cidrbyte_mgmt = [
    for i in range(1, 4) : var.cidrbyte["mgmt${i}.${var.aws_region}"]
  ]

  cidrbyte_sql = [
    for i in range(1, 4) : var.cidrbyte["sql${i}.${var.aws_region}"]
  ]

  cidrbyte_web = [
    for i in range(1, 4) : var.cidrbyte["web${i}.${var.aws_region}"]
  ]
}

module "dynamodb" {
  source = "./dynamodb"
}
