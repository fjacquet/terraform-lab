resource "aws_route53_record" "dc" {
  count   = var.aws_number
  zone_id = var.dns_zone_id
  name    = "dc-${count.index}.${var.dns_suffix}"
  type    = "A"
  ttl     = "300"
  records = [element(aws_instance.dc.*.private_ip, count.index)]
}

# resource "aws_route53_record" "dc-v6" {
#   count   = "${var.aws_number}"
#   zone_id = "${var.dns_zone_id}"
#   name    = "dc-${count.index}.${var.dns_suffix}"
#   type    = "AAAA"
#   ttl     = "300"
#   records = ["${aws_instance.dc.*.ipv6_addresses}"]
# }

resource "aws_instance" "dc" {
  ami                  = var.aws_ami
  availability_zone    = element(var.azs, count.index)
  count                = var.aws_number
  iam_instance_profile = var.aws_iip_assumerole_name
  instance_type        = "t3.medium"
  ipv6_address_count   = 1
  key_name             = var.aws_key_pair_auth_id
  subnet_id            = element(var.aws_subnet_id, count.index)
  user_data            = file("user_data/config-win.ps1")

  metadata_options {
    http_tokens                 = "required"
    http_put_response_hop_limit = "1"
  }
  root_block_device {
    encrypted = true
  }

  tags = {
    Name        = "dc-${count.index}"
    Environment = "lab"
    type        = "adds"
    system      = "windows"
  }

  lifecycle {
    ignore_changes = [user_data]
  }

  # Our Security group to allow RDP access
  vpc_security_group_ids = var.aws_sg_ids
}

resource "aws_security_group" "dc" {
  name        = "tf_ezlab_dc"
  description = "Used in the terraform"
  vpc_id      = var.aws_vpc_id

  # DNS (53/tcp and 53/udp)
  # Kerberos-Sec (TCP) (88/tcp)
  # Kerberos-Sec (UDP) (88/udp)
  # LDAP (389/tcp)
  # LDAP (UDP) (389/udp)
  # LDAPS (636/tcp)
  # LDAP GC (Global Catalog) (3268/tcp)
  # LDAPS GC (Global Catalog) (3269/tcp)
  # Microsoft CIFS (TCP) (445/tcp)
  # Microsoft CIFS (UDP) (445/udp)
  # NetBios Datagram (138/udp)
  # NetBios Name Service (137/udp)
  # NetBios Session (139/tcp)
  # NTP (UDP) (123/udp)
  # PING (ICMP Type 8)
  # RPC (all interfaces) (135/tcp)

  ingress {
    description = "ping"
    from_port   = 8
    to_port     = 8
    protocol    = "icmp"
    self        = true
  }
  ingress {
    description = "ntp"
    from_port   = 123
    to_port     = 123
    protocol    = "udp"
    self        = true
  }
  ingress {
    description = "NetBios Session"
    from_port   = 139
    to_port     = 139
    protocol    = "tcp"
    self        = true
  }
  ingress {
    description = "NetBios"
    from_port   = 137
    to_port     = 138
    protocol    = "udp"
    self        = true
  }
  ingress {
    description = "SMB"
    from_port   = 445
    to_port     = 445
    protocol    = "tcp"
    self        = true
  }
  ingress {
    description = "SMB"
    from_port   = 445
    to_port     = 445
    protocol    = "udp"
    self        = true
  }
  ingress {
    description     = "PKI Kerberos"
    from_port       = 464
    to_port         = 464
    protocol        = "tcp"
    security_groups = [var.aws_sg_domain_member]
  }
  ingress {
    description = "LDAP GC"
    from_port   = 3268
    to_port     = 3269
    protocol    = "tcp"
    self        = true
  }
  ingress {
    description = "LDAPS"
    from_port   = 636
    to_port     = 636
    protocol    = "tcp"
    self        = true
  }
  ingress {
    description = "LDAPS"
    from_port   = 636
    to_port     = 636
    protocol    = "udp"
    self        = true
  }
  ingress {
    description = "LDAP"
    from_port   = 389
    to_port     = 389
    protocol    = "tcp"
    self        = true
  }
  ingress {
    description = "LDAP"
    from_port   = 389
    to_port     = 389
    protocol    = "udp"
    self        = true
  }
  ingress {
    description = "kerberos"
    from_port   = 88
    to_port     = 88
    protocol    = "tcp"
    self        = true
  }
  ingress {
    description = "kerberos"
    from_port   = 88
    to_port     = 88
    protocol    = "udp"
    self        = true
  }
  ingress {
    description = "dns"
    from_port   = 53
    to_port     = 53
    protocol    = "tcp"
    self        = true
  }
  ingress {
    description = "dns"
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    self        = true
  }
  ingress {
    description = "RPC"
    from_port   = 135
    to_port     = 135
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
