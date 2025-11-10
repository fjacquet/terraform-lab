locals {
  # Common tags applied to all resources
  common_tags = {
    Project     = "terraform-lab"
    ManagedBy   = "Terraform"
    Environment = "lab"
    Repository  = "github.com/fjacquet/terraform-lab"
  }

  # Admin CIDR blocks - use public access if enabled, otherwise use restricted blocks
  admin_cidr_blocks = var.enable_public_admin_access ? ["0.0.0.0/0"] : var.admin_cidr_blocks

  # Computed CIDR blocks for all subnet types
  # These are dynamically generated based on the number of availability zones
  cidr_blocks = {
    back = [
      for i in range(length(var.azs)) :
      cidrsubnet(module.global.vpc_cidr, 8, var.cidrbyte["back${i + 1}.${var.aws_region}"])
    ]

    backup = [
      for i in range(length(var.azs)) :
      cidrsubnet(module.global.vpc_cidr, 8, var.cidrbyte["backup${i + 1}.${var.aws_region}"])
    ]

    web = [
      for i in range(length(var.azs)) :
      cidrsubnet(module.global.vpc_cidr, 8, var.cidrbyte["web${i + 1}.${var.aws_region}"])
    ]

    exchange = [
      for i in range(length(var.azs)) :
      cidrsubnet(module.global.vpc_cidr, 8, var.cidrbyte["exchange${i + 1}.${var.aws_region}"])
    ]

    mgmt = [
      for i in range(length(var.azs)) :
      cidrsubnet(module.global.vpc_cidr, 8, var.cidrbyte["mgmt${i + 1}.${var.aws_region}"])
    ]

    sql = [
      for i in range(length(var.azs)) :
      cidrsubnet(module.global.vpc_cidr, 8, var.cidrbyte["sql${i + 1}.${var.aws_region}"])
    ]
  }
}
