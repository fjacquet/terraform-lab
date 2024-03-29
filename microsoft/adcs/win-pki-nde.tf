resource "aws_route53_record" "pki-nde" {
  count   = var.aws_number_pki-ndes
  zone_id = var.dns_zone_id
  name    = "pki-nde-${count.index}.${var.dns_suffix}"
  type    = "A"
  ttl     = "300"
  records = [element(aws_instance.pki-nde.*.private_ip, count.index)]
}

# resource "aws_route53_record" "pki-nde-v6" {
#   count   = "${var.aws_number_pki-ndes}"
#   zone_id = "${var.dns_zone_id}"
#   name    = "pki-nde-${count.index}.${var.dns_suffix}"
#   type    = "AAAA"
#   ttl     = "300"
#   records = ["${aws_instance.pki-nde.*.ipv6_addresses}"]
# }

resource "aws_instance" "pki-nde" {
  ami                  = var.aws_ami
  availability_zone    = element(var.azs, count.index)
  count                = var.aws_number_pki-ndes
  iam_instance_profile = var.aws_iip_assumerole_name
  instance_type        = "t3.medium"
  ipv6_address_count   = 1
  key_name             = var.aws_key_pair_auth_id
  subnet_id            = element(var.aws_subnet_id, count.index)
  user_data            = file("user_data/config-win.ps1")

  root_block_device {
    encrypted = true
  }
  metadata_options {
    http_tokens                 = "required"
    http_put_response_hop_limit = "1"
  }
  tags = {
    Name        = "pki-nde-${count.index}"
    Environment = "lab"
    type        = "ndes"
    system      = "windows"
  }

  lifecycle {
    ignore_changes = [user_data]
  }

  depends_on = [
    aws_instance.pki-ica,
  ]
  # Our Security group to allow RDP access
  vpc_security_group_ids = var.aws_sg_ids
}

# A security group for basic windows box
resource "aws_security_group" "pki-ndes" {
  name        = "tf_ezlab_pki-ndes"
  description = "Used in the terraform"
  vpc_id      = var.aws_vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
    cidr_blocks = var.cidr
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
