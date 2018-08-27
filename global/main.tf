module "iam" {
  source = "./iam/"
}

module "route53" {
  source = "./route53"
}

module "s3" {
  source = "./s3"
}

module "demand" {
  source = "./demand"
}

module "vpc" {
  source = "./vpc"
}
