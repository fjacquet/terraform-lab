resource "aws_route53_record" "wds" {
  count   = var.aws_number
  zone_id = var.dns_zone_id
  name    = "wds-${count.index}.${var.dns_suffix}"
  type    = "A"
  ttl     = "300"
  records = [element(aws_instance.wds.*.private_ip, count.index)]
}

# resource "aws_route53_record" "wds-v6" {
#   count   = "${var.aws_number}"
#   zone_id = "${var.dns_zone_id}"
#   name    = "wds-${count.index}.${var.dns_suffix}"
#   type    = "AAAA"
#   ttl     = "300"
#   records = ["${aws_instance.wds.*.ipv6_addresses}"]
# }

resource "aws_instance" "wds" {
  instance_type        = "t3.medium"
  count                = var.aws_number
  availability_zone    = element(var.azs, count.index)
  subnet_id            = element(var.aws_subnet_id, count.index)
  ami                  = var.aws_ami
  ipv6_address_count   = 1
  user_data            = file("user_data/config-win.ps1")
  key_name             = var.aws_key_pair_auth_id
  iam_instance_profile = var.aws_iip_assumerole_name

  root_block_device {
    volume_size = 250
  }

  tags = {
    Name        = "wds-${count.index}"
    Environment = "lab"
    type        = "wds"
  }

  lifecycle {
    ignore_changes = [user_data]
  }

  # Our Security group to allow RDP access
  vpc_security_group_ids = var.aws_sg_ids
}

resource "aws_security_group" "wds" {
  name        = "tf_ezlab_wds"
  description = "Used in the terraform"
  vpc_id      = var.aws_vpc_id

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
    from_port   = 8530
    to_port     = 8531
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
