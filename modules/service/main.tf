# ============================================================================
# UNIFIED SERVICE MODULE
# Single module that handles ALL services (Windows + Unix)
# ============================================================================

locals {
  # Common egress rules - allow all outbound traffic
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

  # Determine subnet IDs based on subnet_type
  subnet_ids = (
    var.config.subnet_type == "back" ? var.subnets.back :
    var.config.subnet_type == "web" ? var.subnets.web :
    var.config.subnet_type == "mgmt" ? var.subnets.mgmt :
    var.config.subnet_type == "exchange" ? var.subnets.exchange :
    var.config.subnet_type == "backup" ? var.subnets.backup :
    var.subnets.back # default
  )

  # Determine CIDR blocks (with override support)
  cidr_blocks = (
    lookup(var.config, "skip_cidr", false) ? [] :
    lookup(var.config, "cidr_override", null) != null ? var.cidr_blocks[var.config.cidr_override] :
    var.cidr_blocks[var.config.subnet_type]
  )

  # Determine AMI ID based on ami_type
  ami_id = var.ami_ids[var.config.ami_type]

  # Determine user data file
  user_data_file = var.config.user_data

  # Build security group IDs list
  base_sg_ids = (
    var.config.os_type == "windows" ? [
      var.security_groups.rdp,
      var.security_groups.domain_member,
      var.security_groups.simpana_client,
    ] :
    var.config.os_type == "bsd" ? [] :
    [var.security_groups.ssh] # Unix/Linux
  )

  # Add service-specific security group if it creates one
  service_sg_ids = lookup(var.config, "creates_sg", false) ? [aws_security_group.service[0].id] : []

  # Combine all security groups
  all_sg_ids = concat(local.base_sg_ids, local.service_sg_ids, var.nbu_client_sg_ids)
}

# ============================================================================
# EC2 INSTANCES
# ============================================================================

resource "aws_instance" "service" {
  count                = var.instance_count
  ami                  = local.ami_id
  availability_zone    = element(var.azs, count.index)
  iam_instance_profile = var.iam_instance_profile
  instance_type        = var.config.instance_type
  ipv6_address_count   = 1
  key_name             = var.key_pair_id
  subnet_id            = element(local.subnet_ids, count.index)
  user_data            = file(local.user_data_file)

  metadata_options {
    http_tokens                 = var.common_metadata_options.http_tokens
    http_put_response_hop_limit = var.common_metadata_options.http_put_response_hop_limit
    http_endpoint               = var.common_metadata_options.http_endpoint
  }

  root_block_device {
    volume_size = var.config.root_volume_size
    encrypted   = var.common_root_block_device.encrypted
  }

  tags = {
    Name        = "${var.service_name}-${count.index}"
    Environment = "lab"
    type        = var.service_name
    system      = var.config.os_type
  }

  lifecycle {
    ignore_changes = [user_data]
  }

  vpc_security_group_ids = local.all_sg_ids
}

# ============================================================================
# SECURITY GROUP (if service creates one)
# ============================================================================

resource "aws_security_group" "service" {
  count       = lookup(var.config, "creates_sg", false) ? 1 : 0
  name        = "tf_ezlab_${var.service_name}"
  description = "Security group for ${var.service_name} service"
  vpc_id      = var.vpc_id

  # Dynamic ingress rules based on service configuration
  dynamic "ingress" {
    for_each = lookup(var.config, "ingress_rules", [])
    content {
      description      = ingress.value.description
      from_port        = ingress.value.from_port
      to_port          = ingress.value.to_port
      protocol         = ingress.value.protocol
      cidr_blocks      = lookup(ingress.value, "cidr_blocks", null)
      ipv6_cidr_blocks = lookup(ingress.value, "ipv6_cidr_blocks", null)
      self             = lookup(ingress.value, "self", null)
      security_groups  = lookup(ingress.value, "security_groups", null)
    }
  }

  # Dynamic egress rules
  dynamic "egress" {
    for_each = local.common_egress_rules
    content {
      description      = egress.value.description
      from_port        = egress.value.from_port
      to_port          = egress.value.to_port
      protocol         = egress.value.protocol
      cidr_blocks      = egress.value.cidr_blocks
      ipv6_cidr_blocks = egress.value.ipv6_cidr_blocks
    }
  }
}

# ============================================================================
# ROUTE53 DNS RECORDS
# ============================================================================

# Private DNS record
resource "aws_route53_record" "private" {
  count   = var.instance_count
  zone_id = var.dns_zone_id
  name    = "${var.service_name}-${count.index}.${var.dns_suffix}"
  type    = "A"
  ttl     = "300"
  records = [element(aws_instance.service.*.private_ip, count.index)]
}

# Public DNS record (if service has public DNS)
resource "aws_route53_record" "public" {
  count   = lookup(var.config, "has_public_dns", false) ? var.instance_count : 0
  zone_id = var.dns_public_zone_id
  name    = "${var.service_name}-${count.index}.${var.dns_suffix}"
  type    = "A"
  ttl     = "300"
  records = [element(aws_instance.service.*.public_ip, count.index)]
}

# Extra public DNS records (e.g., bastion alias for guacamole)
resource "aws_route53_record" "extra_public" {
  for_each = lookup(var.config, "has_public_dns", false) ? toset(lookup(var.config, "extra_dns_names", [])) : toset([])
  zone_id  = var.dns_public_zone_id
  name     = "${each.value}-0.${var.dns_suffix}"
  type     = "A"
  ttl      = "300"
  records  = [aws_instance.service[0].public_ip]
}

# ============================================================================
# ADDITIONAL EBS VOLUMES (for services like NBU)
# ============================================================================

resource "aws_ebs_volume" "extra" {
  for_each          = lookup(var.config, "extra_volumes", {})
  availability_zone = aws_instance.service[0].availability_zone
  size              = each.value
  encrypted         = var.common_root_block_device.encrypted

  tags = {
    Name = "${var.service_name}-${each.key}"
  }
}

resource "aws_volume_attachment" "extra" {
  for_each    = lookup(var.config, "extra_volumes", {})
  device_name = "/dev/sd${substr("fghijklmnop", index(keys(var.config.extra_volumes), each.key), 1)}"
  volume_id   = aws_ebs_volume.extra[each.key].id
  instance_id = aws_instance.service[0].id
}
