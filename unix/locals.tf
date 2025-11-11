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

  # Common egress rules for all security groups
  # Eliminates duplication of identical egress blocks across Unix security groups
  common_egress_rules = [
    {
      description      = "Allow all outbound IPv4 traffic"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
    },
    {
      description      = "Allow all outbound IPv6 traffic"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = []
      ipv6_cidr_blocks = ["::/0"]
    }
  ]

  # Common instance metadata options - enforces IMDSv2
  # Eliminates duplication across all EC2 instance resources
  common_instance_metadata_options = {
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    http_endpoint               = "enabled"
  }

  # Common instance root block device configuration
  # Ensures all instances have encrypted root volumes
  common_instance_root_block_device = {
    encrypted = true
  }
}
