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
}

resource "aws_route53_record" "ipam" {
  count   = var.aws_number
  zone_id = var.dns_zone_id
  name    = "ipam-${count.index}.${var.dns_suffix}"
  type    = "A"
  ttl     = "300"
  records = [element(aws_instance.ipam.*.private_ip, count.index)]
}

# resource "aws_route53_record" "ipam-v6" {
#   count   = "${var.aws_number}"
#   zone_id = "${var.dns_zone_id}"
#   name    = "ipam-${count.index}.${var.dns_suffix}"
#   type    = "AAAA"
#   ttl     = "300"
#   records = ["${aws_instance.ipam.*.ipv6_addresses}"]
# }

resource "aws_instance" "ipam" {
  instance_type        = "t3.medium"
  count                = var.aws_number
  availability_zone    = element(var.azs, count.index)
  subnet_id            = element(var.aws_subnet_id, count.index)
  ami                  = var.aws_ami
  ipv6_address_count   = 1
  user_data            = file("user_data/config-win.ps1")
  key_name             = var.aws_key_pair_auth_id
  iam_instance_profile = var.aws_iip_assumerole_name

  tags = {
    Name        = "ipam-${count.index}"
    Environment = "lab"
    type        = "ipam"
    system      = "windows"
  }

  lifecycle {
    ignore_changes = [user_data]
  }
  metadata_options {
    http_tokens                 = var.common_instance_metadata_options.http_tokens
    http_put_response_hop_limit = var.common_instance_metadata_options.http_put_response_hop_limit
    http_endpoint               = var.common_instance_metadata_options.http_endpoint
  }

  root_block_device {
    encrypted = var.common_instance_root_block_device.encrypted
  }

  # Our Security group to allow RDP access
  vpc_security_group_ids = var.aws_sg_ids
}

resource "aws_security_group" "ipam" {
  name        = "tf_ezlab_ipam"
  description = "Used in the terraform"
  vpc_id      = var.aws_vpc_id

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    self      = true
  }

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
    self      = true
  }

  ingress {
    from_port = 3702
    to_port   = 3702
    protocol  = "udp"
    self      = true
  }

  # Dynamic egress rules - eliminates code duplication
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
