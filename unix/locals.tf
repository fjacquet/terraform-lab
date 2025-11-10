locals {
  # Common configuration for all Unix/Linux modules
  # This reduces duplication across module calls by centralizing shared parameters
  common_unix_config = {
    aws_iip_assumerole_name = var.aws_iip_assumerole_name
    aws_key_pair_auth_id    = var.aws_key_pair_auth_id
    aws_region              = var.aws_region
    aws_vpc_id              = var.aws_vpc_id
    azs                     = var.azs
    dns_zone_id             = var.dns_zone_id
    dns_suffix              = var.dns_suffix
    dns_public_zone_id      = var.dns_public_zone_id
  }

  # Common security groups for Unix/Linux servers
  # These are the base security groups that most Unix instances need
  common_unix_sg_ids = flatten([
    aws_security_group.ssh.id,
    var.aws_sg_simpana_client_id,
    module.nbu.aws_sg_client_ids,
  ])

  # CIDR blocks passed from root module
  # These are computed in the root locals.tf and passed as a variable
  cidr_blocks = var.cidr_blocks
}
