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

resource "aws_route53_record" "sharepoint" {
  count   = var.aws_number
  zone_id = var.dns_zone_id
  name    = "sharepoint-${count.index}.${var.dns_suffix}"
  type    = "A"
  ttl     = "300"
  records = [element(aws_instance.sharepoint.*.private_ip, count.index)]
}

# resource "aws_route53_record" "sharepoint-v6" {
#   count   = "${var.aws_number}"
#   zone_id = "${var.dns_zone_id}"
#   name    = "sharepoint-${count.index}.${var.dns_suffix}"
#   type    = "AAAA"
#   ttl     = "300"
#   records = ["${aws_instance.sharepoint.*.ipv6_addresses}"]
# }

resource "aws_instance" "sharepoint" {
  ami                  = var.aws_ami
  availability_zone    = element(var.azs, count.index)
  count                = var.aws_number
  ebs_optimized        = "true"
  iam_instance_profile = var.aws_iip_assumerole_name
  instance_type        = "m5.xlarge"
  ipv6_address_count   = 1
  key_name             = var.aws_key_pair_auth_id
  subnet_id            = element(var.aws_subnet_id, count.index)
  user_data            = file("user_data/config-win.ps1")

  # Our Security group to allow Sharepoint access
  vpc_security_group_ids = var.aws_sg_ids

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

  tags = {
    Name        = "sharepoint-${count.index}"
    Environment = "lab"
    type        = "sharepoint"
    system      = "windows"
  }
}

resource "aws_security_group" "sharepoint" {
  name        = "tf_ezlab_sharepoint"
  description = "Access to Sharepoint"
  vpc_id      = var.aws_vpc_id

  # HTTPS access from anywhere
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  # HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
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
