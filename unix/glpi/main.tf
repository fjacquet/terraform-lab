resource "aws_instance" "glpi" {
  instance_type          = "t3.medium"
  count                  = var.aws_number
  subnet_id              = element(var.aws_subnet_id, count.index)
  user_data              = file("user_data/config-linux.sh")
  iam_instance_profile   = var.aws_iip_assumerole_name
  ami                    = var.aws_ami
  ipv6_address_count     = 1
  key_name               = var.aws_key_pair_auth_id
  vpc_security_group_ids = var.aws_sg_ids

  root_block_device {
    volume_size = 80
    encrypted   = true
  }

  tags = {
    Name        = "glpi-${count.index}"
    Environment = "lab"
    type        = "glpi"
    system      = "debian"
  }
  metadata_options {
    http_tokens = "required"
  }


  lifecycle {
    ignore_changes = [user_data]
  }
}

resource "aws_security_group" "glpi" {
  name        = "tf_ezlab_glpi"
  description = "Used in the terraform"
  vpc_id      = var.aws_vpc_id


  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  ingress {
    from_port   = 9090
    to_port     = 9090
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

resource "aws_route53_record" "glpi" {
  count   = var.aws_number
  zone_id = var.dns_zone_id
  name    = "glpi-${count.index}.${var.dns_suffix}"
  type    = "A"
  ttl     = "300"
  records = [element(aws_instance.glpi.*.private_ip, count.index)]
}

# resource "aws_route53_record" "glpi-v6" {
#   count   = "${var.aws_number}"
#   zone_id = "${var.dns_zone_id}"
#   name    = "glpi-${count.index}.{var.dns_suffix}"
#   type    = "AAAA"
#   ttl     = "300"
#   records = ["${aws_instance.glpi.*.ipv6_addresses}"]
# }
