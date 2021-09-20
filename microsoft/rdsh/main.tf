resource "aws_route53_record" "rdsh" {
  count   = var.aws_number
  zone_id = var.dns_zone_id
  name    = "rdsh-${count.index}.${var.dns_suffix}"
  type    = "A"
  ttl     = "300"
  records = [element(aws_instance.rdsh.*.private_ip, count.index)]
}

# resource "aws_route53_record" "fs-v6" {
#   count   = "${var.aws_number}"
#   zone_id = "${var.dns_zone_id}"
#   name    = "fs-${count.index}.${var.dns_suffix}"
#   type    = "AAAA"
#   ttl     = "300"
#   records = ["${aws_instance.fs.*.ipv6_addresses}"]
# }

resource "aws_instance" "rdsh" {
  ami                  = var.aws_ami
  availability_zone    = element(var.azs, count.index)
  count                = var.aws_number
  iam_instance_profile = var.aws_iip_assumerole_name
  instance_type        = "m5.xlarge"
  ipv6_address_count   = 1
  key_name             = var.aws_key_pair_auth_id
  subnet_id            = element(var.aws_subnet_id, count.index)
  user_data            = file("user_data/config-win.ps1")

  tags = {
    Name        = "rdsh-${count.index}"
    Environment = "lab"
    type        = "rdsh"
    system      = "windows"
  }

  root_block_device {
    volume_size = 250
  }

  lifecycle {
    ignore_changes = [user_data]
  }

  # Our Security group to allow RDP access
  vpc_security_group_ids = var.aws_sg_ids
}

resource "aws_security_group" "rdsh" {
  name        = "tf_ezlab_rdsh"
  description = "Used in the terraform"
  vpc_id      = var.aws_vpc_id

  ingress {
    description     = "file Server"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [var.aws_sg_domain_members]
  }

  ingress {
    description     = "file Server"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [var.aws_sg_domain_members]
  }

  ingress {
    description = "ping"
    from_port   = 8
    to_port     = 8
    protocol    = "icmp"
    self        = true
  }

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
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
