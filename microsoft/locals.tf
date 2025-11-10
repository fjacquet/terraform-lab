locals {
  # Common configuration for all Windows modules
  # This reduces duplication across module calls by centralizing shared parameters
  common_windows_config = {
    aws_ami                 = data.aws_ami.windows2022.id
    aws_iip_assumerole_name = var.aws_iip_assumerole_name
    aws_key_pair_auth_id    = var.aws_key_pair_auth_id
    aws_region              = var.aws_region
    aws_vpc_id              = var.aws_vpc_id
    azs                     = var.azs
    dns_zone_id             = var.dns_zone_id
    dns_suffix              = var.dns_suffix
    dns_public_zone_id      = var.dns_public_zone_id
  }

  # CIDR blocks passed from root module
  # These are computed in the root locals.tf and passed as a variable
  cidr_blocks = var.cidr_blocks

  # Common security groups for Windows servers
  # These are the base security groups that most Windows instances need
  common_windows_sg_ids = flatten([
    aws_security_group.rdp.id,
    aws_security_group.domain-member.id,
    module.simpana.aws_sg_client_id,
    var.aws_sg_nbuclient_ids,
  ])

  # Subnet-specific security groups
  # Different subnets may have different security requirements
  back_subnet_sg_ids = local.common_windows_sg_ids

  web_subnet_sg_ids = local.common_windows_sg_ids

  mgmt_subnet_sg_ids = local.common_windows_sg_ids
}
