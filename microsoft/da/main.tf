resource "aws_route53_record" "da" {
  count   = var.aws_number
  zone_id = var.dns_zone_id
  name    = "da-${count.index}.${var.dns_suffix}"
  type    = "A"
  ttl     = "300"
  records = [element(aws_instance.da.*.private_ip, count.index)]
}

# resource "aws_route53_record" "da-v6" {
#   count   = "${var.aws_number}"
#   zone_id = "${var.dns_zone_id}"
#   name    = "da-${count.index}.${var.dns_suffix}"
#   type    = "AAAA"
#   ttl     = "300"
#   records = ["${aws_instance.da.*.ipv6_addresses}"]
# }

resource "aws_instance" "da" {
  instance_type        = "t3.medium"
  count                = var.aws_number
  availability_zone    = element(var.azs, count.index)
  iam_instance_profile = var.aws_iip_assumerole_name
  ami                  = var.aws_ami
  ipv6_address_count   = 1
  key_name             = var.aws_key_pair_auth_id
  user_data            = file("user_data/config-da.ps1")
  subnet_id            = element(var.aws_subnet_id, count.index)

  tags = {
    Name        = "da-${count.index}"
    Environment = "lab"
  }

  lifecycle {
    ignore_changes = [user_data]
  }

  # Our Security group to allow RDP access
  vpc_security_group_ids = var.aws_sg_ids
}

resource "aws_security_group" "da" {
  name        = "tf_ezlab_da"
  description = "Used in the terraform"
  vpc_id      = var.aws_vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/16"]
  }

  ingress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    ipv6_cidr_blocks = ["::/0"]
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
