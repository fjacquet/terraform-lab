# ============================================================================
# TERRAFORM-LAB ROOT MODULE
# Modern 2-level architecture: root → unified service module
# ============================================================================

# ============================================================================
# GLOBAL INFRASTRUCTURE
# VPC, subnets, IAM roles, Route53 zones, VPC endpoints
# ============================================================================

module "global" {
  source = "./global"

  access_key    = var.access_key
  aws_number    = var.aws_number
  aws_region    = var.aws_region
  azs           = var.azs
  cidrbyte      = var.cidrbyte
  dns_suffix    = var.dns_suffix
  public_dns_id = var.public_dns_id
  key_name      = var.key_name
  public_key    = var.public_key
  secret_key    = var.secret_key
}

# ============================================================================
# UNIFIED SERVICE DEPLOYMENT
# Single for_each loop deploys ALL 23 services (Windows + Unix)
# Services are configured in locals.tf
# Security groups are defined in security-groups.tf
# AMI lookups are in data-sources.tf
# ============================================================================

module "services" {
  for_each = { for k, v in local.all_services : k => v if lookup(var.aws_number, k, 0) > 0 }

  source = "./modules/service"

  # Service identification
  service_name   = each.key
  instance_count = var.aws_number[each.key]
  config         = each.value

  # Common configuration (passed once for all services)
  ami_ids                  = local.ami_ids
  common_metadata_options  = local.common_instance_metadata_options
  common_root_block_device = local.common_instance_root_block_device

  # Network configuration
  vpc_id      = module.global.aws_vpc_id
  subnets     = local.subnet_map
  cidr_blocks = local.cidr_blocks

  # Instance configuration
  azs                  = var.azs
  iam_instance_profile = module.global.aws_iip_assumerole
  key_pair_id          = aws_key_pair.auth.id

  # DNS configuration
  dns_zone_id        = module.global.dns_zone_id
  dns_public_zone_id = var.public_dns_id
  dns_suffix         = var.dns_suffix

  # Security groups
  security_groups = local.security_group_map

  # NBU client security groups (for services that need backup client access)
  nbu_client_sg_ids = try([module.services["nbu"].security_group_id], [])
}
