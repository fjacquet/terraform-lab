resource "aws_route53_record" "nps" {
  count   = var.aws_number
  zone_id = var.dns_zone_id
  name    = "nps-${count.index}.${var.dns_suffix}"
  type    = "A"
  ttl     = "300"
  records = [element(aws_instance.nps.*.private_ip, count.index)]
}

# resource "aws_route53_record" "nps-v6" {
#   count   = "${var.aws_number}"
#   zone_id = "${var.dns_zone_id}"
#   name    = "nps-${count.index}.${var.dns_suffix}"
#   type    = "AAAA"
#   ttl     = "300"
#   records = ["${aws_instance.nps.*.ipv6_addresses}"]
# }

resource "aws_instance" "nps" {
  ami                  = var.aws_ami
  availability_zone    = element(var.azs, count.index)
  count                = var.aws_number
  iam_instance_profile = var.aws_iip_assumerole_name
  instance_type        = "t3.medium"
  ipv6_address_count   = 1
  key_name             = var.aws_key_pair_auth_id
  subnet_id            = element(var.aws_subnet_id, count.index)
  user_data            = file("user_data/config-nps.ps1")

  tags = {
    Name        = "nps-${count.index}"
    Environment = "lab"
  }

  lifecycle {
    ignore_changes = [user_data]
  }

  # Our Security group to allow RDP access
  vpc_security_group_ids = var.aws_sg_ids
}

resource "aws_security_group" "nps" {
  name        = "tf_evlab_nps"
  description = "Used in the terraform"
  vpc_id      = var.aws_vpc_id

  ingress {
    description = "Radius legacy Server"
    from_port   = 1645
    to_port     = 1646
    protocol    = "udp"
    self        = true
  }

  ingress {
    description = "Radius  Server"
    from_port   = 1812
    to_port     = 1813
    protocol    = "udp"
    self        = true
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

