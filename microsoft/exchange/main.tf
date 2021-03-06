resource "aws_route53_record" "exchange" {
  count   = var.aws_number
  zone_id = var.dns_zone_id
  name    = "exchange-${count.index}.${var.dns_suffix}"
  type    = "A"
  ttl     = "300"
  records = [element(aws_instance.exchange.*.private_ip, count.index)]
}

# resource "aws_route53_record" "exchange-v6" {
#   count   = "${var.aws_number}"
#   zone_id = "${var.dns_zone_id}"
#   name    = "exchange-${count.index}.${var.dns_suffix}"
#   type    = "AAAA"
#   ttl     = "300"
#   records = ["${aws_instance.exchange.*.ipv6_addresses}"]
# }

resource "aws_instance" "exchange" {
  ami                  = var.aws_ami
  availability_zone    = element(var.azs, count.index)
  count                = var.aws_number
  ebs_optimized        = "true"
  iam_instance_profile = var.aws_iip_assumerole_name
  instance_type        = "m4.large"
  ipv6_address_count   = 1
  key_name             = var.aws_key_pair_auth_id
  subnet_id            = element(var.aws_subnet_id, count.index)
  user_data            = file("user_data/config-exchange.ps1")

  root_block_device {
    volume_size = 100
  }

  tags = {
    Name        = "exchange-${count.index}"
    Environment = "lab"
  }

  lifecycle {
    ignore_changes = [user_data]
  }

  # Our Security group to allow RDP access
  vpc_security_group_ids = var.aws_sg_ids
}

resource "aws_security_group" "exchange" {
  name        = "tf_evlab_windows_exchange"
  description = "Used in the terraform"
  vpc_id      = var.aws_vpc_id

  # LDAP
  ingress {
    from_port = 389
    to_port   = 389
    protocol  = "tcp"
    cidr_blocks = [element(var.cidr, count.index)]
  }

  # LDAP
  ingress {
    from_port = 389
    to_port   = 389
    protocol  = "udp"
    cidr_blocks = [element(var.cidr, count.index)]
  }

  # LDAP
  ingress {
    from_port = 379
    to_port   = 379
    protocol  = "tcp"
    cidr_blocks = [element(var.cidr, count.index)]
  }

  # LDAP
  ingress {
    from_port = 3268
    to_port   = 3269
    protocol  = "tcp"
    cidr_blocks = [element(var.cidr, count.index)]
  }

  # LDAP
  ingress {
    from_port = 636
    to_port   = 636
    protocol  = "tcp"
    cidr_blocks = [element(var.cidr, count.index)]
  }

  # IMAP
  ingress {
    from_port = 143
    to_port   = 143
    protocol  = "tcp"
    cidr_blocks = [element(var.cidr, count.index)]
  }

  # IMAPS
  ingress {
    from_port = 993
    to_port   = 993
    protocol  = "tcp"
    cidr_blocks = [element(var.cidr, count.index)]
  }

  # POP
  ingress {
    from_port = 110
    to_port   = 110
    protocol  = "tcp"
    cidr_blocks = [element(var.cidr, count.index)]
  }

  # POPS
  ingress {
    from_port = 995
    to_port   = 995
    protocol  = "tcp"
    cidr_blocks = [element(var.cidr, count.index)]
  }

  # NNTP
  ingress {
    from_port = 119
    to_port   = 119
    protocol  = "tcp"
    # TF-UPGRADE-TODO: In Terraform v0.10 and earlier, it was sometimes necessary to
    # force an interpolation expression to be interpreted as a list by wrapping it
    # in an extra set of list brackets. That form was supported for compatibility in
    # v0.11, but is no longer supported in Terraform v0.12.
    #
    # If the expression in the following list itself returns a list, remove the
    # brackets to avoid interpretation as a list of lists. If the expression
    # returns a single list item then leave it as-is and remove this TODO comment.
    cidr_blocks = [element(var.cidr, count.index)]
  }

  # NNTP
  ingress {
    from_port = 563
    to_port   = 563
    protocol  = "tcp"
    cidr_blocks = [element(var.cidr, count.index)]
  }

  # SMTP
  ingress {
    from_port = 25
    to_port   = 25
    protocol  = "tcp"
    cidr_blocks = [element(var.cidr, count.index)]
  }

  # SMTP
  ingress {
    from_port = 465
    to_port   = 465
    protocol  = "tcp"
    cidr_blocks = [element(var.cidr, count.index)]
  }

  # SMTP
  ingress {
    from_port = 691
    to_port   = 691
    protocol  = "tcp"
    cidr_blocks = [element(var.cidr, count.index)]
  }

  # X400
  ingress {
    from_port = 102
    to_port   = 102
    protocol  = "tcp"
    cidr_blocks = [element(var.cidr, count.index)]
  }

  # MSRPC
  ingress {
    from_port = 135
    to_port   = 135
    protocol  = "tcp"
    cidr_blocks = [element(var.cidr, count.index)]
  }

  # netbios
  ingress {
    from_port = 137
    to_port   = 138
    protocol  = "udp"
    cidr_blocks = [element(var.cidr, count.index)]
  }

  # netbios
  ingress {
    from_port = 139
    to_port   = 139
    protocol  = "tcp"
    cidr_blocks = [element(var.cidr, count.index)]
  }

  # SAM
  ingress {
    from_port = 445
    to_port   = 445
    protocol  = "udp"
    cidr_blocks = [element(var.cidr, count.index)]
  }

  # SAM
  ingress {
    from_port = 445
    to_port   = 445
    protocol  = "tcp"
    cidr_blocks = [element(var.cidr, count.index)]
  }

  # File Replication
  ingress {
    from_port = 5722
    to_port   = 5722
    protocol  = "tcp"
    cidr_blocks = [element(var.cidr, count.index)]
  }

  # Dynamic range
  ingress {
    from_port = 49152
    to_port   = 65535
    protocol  = "tcp"
    cidr_blocks = [element(var.cidr, count.index)]
  }

  # NTP
  ingress {
    from_port = 123
    to_port   = 123
    protocol  = "udp"
    cidr_blocks = [element(var.cidr, count.index)]
  }

  # kerberos
  ingress {
    from_port = 88
    to_port   = 88
    protocol  = "udp"
    cidr_blocks = [element(var.cidr, count.index)]
  }

  # ULS
  ingress {
    from_port = 522
    to_port   = 522
    protocol  = "tcp"
    cidr_blocks = [element(var.cidr, count.index)]
  }

  # DNS
  ingress {
    from_port = 53
    to_port   = 53
    protocol  = "tcp"
    cidr_blocks = [element(var.cidr, count.index)]
  }

  # DNS
  ingress {
    from_port = 53
    to_port   = 53
    protocol  = "udp"
    cidr_blocks = [element(var.cidr, count.index)]
  }

  # HTTP access from anywhere
  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
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
