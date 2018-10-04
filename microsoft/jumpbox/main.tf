resource "aws_route53_record" "jumpbox" {
  count   = "${var.aws_number}"
  zone_id = "${var.dns_zone_id}"
  name    = "jumpbox-${count.index}.evlab.ch"
  type    = "A"
  ttl     = "300"
  records = ["${element(aws_instance.jumpbox.*.private_ip, count.index)}"]
}

# resource "aws_route53_record" "jumpbox-v6" {
#   count   = "${var.aws_number}"
#   zone_id = "${var.dns_zone_id}"
#   name    = "jumpbox-${count.index}.evlab.ch"
#   type    = "AAAA"
#   ttl     = "300"
#   records = ["${aws_instance.jumpbox.*.ipv6_addresses}"]
# }

resource "aws_eip" "jumpbox-public" {
  count    = "${var.aws_number}"
  instance = "${element(aws_instance.jumpbox.*.id, count.index)}"
  vpc      = true
}

resource "aws_instance" "jumpbox" {
  ami                  = "${var.aws_ami}"
  availability_zone    = "${element(var.azs, count.index)}"
  count                = "${var.aws_number}"
  iam_instance_profile = "${var.aws_iip_assumerole_name}"
  instance_type        = "t2.medium"
  ipv6_address_count   = 1
  key_name             = "${var.aws_key_pair_auth_id}"
  subnet_id            = "${element(var.aws_subnet_id, count.index)}"
  user_data            = "${file("user_data/config-win.ps1")}"

  tags {
    Name = "mgmt-${count.index}"
  }

  lifecycle {
    ignore_changes = ["user_data"]
  }

  # Our Security group to allow RDP access
  vpc_security_group_ids = [
    "${var.aws_sg_ids}",
  ]
}
