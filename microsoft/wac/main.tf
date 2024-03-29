resource "aws_route53_record" "wac" {
  count   = var.aws_number
  zone_id = var.dns_zone_id
  name    = "wac-${count.index}.${var.dns_suffix}"
  type    = "A"
  ttl     = "300"
  records = [element(aws_instance.wac.*.private_ip, count.index)]
}

# resource "aws_route53_record" "wac-v6" {
#   count   = "${var.aws_number}"
#   zone_id = "${var.dns_zone_id}"
#   name    = "wac-${count.index}.${var.dns_suffix}"
#   type    = "AAAA"
#   ttl     = "300"
#   records = ["${aws_instance.wac.*.ipv6_addresses}"]
# }

resource "aws_instance" "wac" {
  instance_type        = "t3.medium"
  count                = var.aws_number
  availability_zone    = element(var.azs, count.index)
  subnet_id            = element(var.aws_subnet_id, count.index)
  ami                  = var.aws_ami
  ipv6_address_count   = 1
  user_data            = file("user_data/config-win.ps1")
  key_name             = var.aws_key_pair_auth_id
  iam_instance_profile = var.aws_iip_assumerole_name

  tags = {
    Name        = "wac-${count.index}"
    Environment = "lab"
    type        = "wac"
    system      = "windows"
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

resource "aws_security_group" "wac" {
  name        = "tf_ezlab_wac"
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
    from_port   = 6516
    to_port     = 6516
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
