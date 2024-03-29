resource "aws_route53_record" "dhcp" {
  count   = var.aws_number
  zone_id = var.dns_zone_id
  name    = "dhcp-${count.index}.${var.dns_suffix}"
  type    = "A"
  ttl     = "300"
  records = [element(aws_instance.dhcp.*.private_ip, count.index)]
}

# resource "aws_route53_record" "dhcp-v6" {
#   count   = "${var.aws_number}"
#   zone_id = "${var.dns_zone_id}"
#   name    = "dhcp-${count.index}.${var.dns_suffix}"
#   type    = "AAAA"
#   ttl     = "300"
#   records = ["${aws_instance.dhcp.*.ipv6_addresses}"]
# }

resource "aws_instance" "dhcp" {
  ami                  = var.aws_ami
  availability_zone    = element(var.azs, count.index)
  count                = var.aws_number
  iam_instance_profile = var.aws_iip_assumerole_name
  instance_type        = "t3.medium"
  ipv6_address_count   = 1
  key_name             = var.aws_key_pair_auth_id
  subnet_id            = element(var.aws_subnet_id, count.index)
  user_data            = file("user_data/config-win.ps1")

  tags = {
    Name        = "dhcp-${count.index}"
    Environment = "lab"
    type        = "dhcp"

    system = "windows"
  }
  metadata_options {
    http_tokens                 = "required"
    http_put_response_hop_limit = "1"
  }

  root_block_device {
    encrypted = true
  }

  lifecycle {
    ignore_changes = [user_data]
  }

  # Our Security group to allow RDP access
  vpc_security_group_ids = var.aws_sg_ids
}

resource "aws_security_group" "dhcp" {
  name        = "tf_ezlab_dhcp"
  description = "Used in the terraform"
  vpc_id      = var.aws_vpc_id

  ingress {
    description = "DHCP Server"
    from_port   = 67
    to_port     = 67
    protocol    = "udp"
    self        = true
  }

  ingress {
    description = "MADCAP"
    from_port   = 2535
    to_port     = 2535
    protocol    = "udp"
    self        = true
  }

  ingress {
    description = "DHCP Failover"
    from_port   = 647
    to_port     = 647
    protocol    = "tcp"
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
