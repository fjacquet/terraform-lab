resource "aws_route53_record" "sharepoint" {
  count   = "${var.aws_number}"
  zone_id = "${var.dns_zone_id}"
  name    = "sharepoint-${count.index}.${var.dns_suffix}"
  type    = "A"
  ttl     = "300"
  records = ["${element(aws_instance.sharepoint.*.private_ip, count.index)}"]
}

# resource "aws_route53_record" "sharepoint-v6" {
#   count   = "${var.aws_number}"
#   zone_id = "${var.dns_zone_id}"
#   name    = "sharepoint-${count.index}.${var.dns_suffix}"
#   type    = "AAAA"
#   ttl     = "300"
#   records = ["${aws_instance.sharepoint.*.ipv6_addresses}"]
# }

resource "aws_instance" "sharepoint" {
  ami                  = "${var.aws_ami}"
  availability_zone    = "${element(var.azs, count.index)}"
  count                = "${var.aws_number}"
  ebs_optimized        = "true"
  iam_instance_profile = "${var.aws_iip_assumerole_name}"
  instance_type        = "m4.xlarge"
  ipv6_address_count   = 1
  key_name             = "${var.aws_key_pair_auth_id}"
  subnet_id            = "${var.aws_subnet_id}"
  user_data            = "${file("user_data/config-sharepoint.ps1")}"

  # Our Security group to allow Sharepoint access
  vpc_security_group_ids = [
    "${var.aws_sg_ids}",
  ]

  lifecycle {
    ignore_changes = ["user_data"]
  }

  tags {
    Name        = "sharepoint-${count.index}"
    Environment = "lab"
  }
}

resource "aws_security_group" "sharepoint" {
  name        = "tf_evlab_sharepoint"
  description = "Access to Sharepoint"
  vpc_id      = "${var.aws_vpc_id}"

  # HTTPS access from anywhere
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
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
