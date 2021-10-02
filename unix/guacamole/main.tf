resource "aws_instance" "guacamole" {
  ami                    = var.aws_ami
  count                  = var.aws_number
  iam_instance_profile   = var.aws_iip_assumerole_name
  instance_type          = "t3.medium"
  ipv6_address_count     = 1
  key_name               = var.aws_key_pair_auth_id
  subnet_id              = element(var.aws_subnet_id, count.index)
  user_data              = file("user_data/config-linux.sh")
  vpc_security_group_ids = var.aws_sg_ids

  root_block_device {
    volume_size = 80
    encrypted   = true
  }

  tags = {
    Name        = "guacamole-${count.index}"
    Environment = "lab"
    type        = "guacamole"
    system      = "debian"
  }
  metadata_options {
    http_tokens = "required"
  }


  lifecycle {
    ignore_changes = [user_data]
  }
}

resource "aws_security_group" "guacamole" {
  name        = "tf_ezlab_guacamole"
  description = "Used in the terraform"
  vpc_id      = var.aws_vpc_id

  # novnc
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # novnc
  ingress {
    from_port   = 6080
    to_port     = 6080
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_route53_record" "guacamole" {
  count   = var.aws_number
  zone_id = var.dns_zone_id
  name    = "guacamole-${count.index}.{var.dns_suffix}"
  type    = "A"
  ttl     = "300"
  records = [element(aws_instance.guacamole.*.private_ip, count.index)]
}

resource "aws_route53_record" "guacamole-public" {
  count   = var.aws_number
  zone_id = var.dns_public_zone_id
  name    = "guacamole-${count.index}.{var.dns_suffix}"
  type    = "A"
  ttl     = "300"
  records = [element(aws_instance.guacamole.*.public_ip, count.index)]
}

resource "aws_route53_record" "bastion-public" {
  count   = var.aws_number
  zone_id = var.dns_public_zone_id
  name    = "bastion-${count.index}.{var.dns_suffix}"
  type    = "A"
  ttl     = "300"
  records = [element(aws_instance.guacamole.*.public_ip, count.index)]
}

# resource "aws_route53_record" "guacamole-v6" {
#   count   = "${var.aws_number}"
#   zone_id = "${var.dns_zone_id}"
#   name    = "guacamole-${count.index}.{var.dns_suffix}"
#   type    = "AAAA"
#   ttl     = "300"
#   records = ["${aws_instance.guacamole.*.ipv6_addresses}"]
# }
