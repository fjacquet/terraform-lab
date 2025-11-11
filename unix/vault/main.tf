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

resource "aws_instance" "vault" {
  instance_type          = "t3.medium"
  count                  = var.aws_number
  subnet_id              = element(var.aws_subnet_id, count.index)
  user_data              = file("user_data/config-linux.sh")
  iam_instance_profile   = var.aws_iip_assumerole_name
  ami                    = var.aws_ami
  ipv6_address_count     = 1
  key_name               = var.aws_key_pair_auth_id
  vpc_security_group_ids = var.aws_sg_ids
  metadata_options {
    http_tokens                 = var.common_instance_metadata_options.http_tokens
    http_put_response_hop_limit = var.common_instance_metadata_options.http_put_response_hop_limit
    http_endpoint               = var.common_instance_metadata_options.http_endpoint
  }
  root_block_device {
    encrypted   = var.common_instance_root_block_device.encrypted
    volume_size = 80
  }

  tags = {
    Name        = "vault-${count.index}"
    Environment = "lab"
    type        = "vault"
    system      = "debian"
  }

  lifecycle {
    ignore_changes = [user_data]
  }
}

resource "aws_security_group" "vault" {
  name        = "tf_ezlab_vault"
  description = "Used in the terraform"
  vpc_id      = var.aws_vpc_id

  ingress {
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
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

resource "aws_route53_record" "vault" {
  count   = var.aws_number
  zone_id = var.dns_zone_id
  name    = "vault-${count.index}.${var.dns_suffix}"
  type    = "A"
  ttl     = "300"
  records = [element(aws_instance.vault.*.private_ip, count.index)]
}

# resource "aws_route53_record" "vault-v6" {
#   count   = "${var.aws_number}"
#   zone_id = "${var.dns_zone_id}"
#   name    = "vault-${count.index}.{var.dns_suffix}"
#   type    = "AAAA"
#   ttl     = "300"
#   records = ["${aws_instance.vault.*.ipv6_addresses}"]
# }
