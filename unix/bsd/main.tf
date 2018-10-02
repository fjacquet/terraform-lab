resource "aws_instance" "bsd" {
  instance_type          = "t2.micro"
  count                  = "${var.aws_number}"
  availability_zone      = "${element(var.azs, count.index)}"
  ami                    = "${var.aws_ami}"
  ipv6_address_count     = 1
  subnet_id              = "${var.aws_subnet_id}"
  key_name               = "${var.aws_key_pair_auth_id}"
  vpc_security_group_ids = "${var.aws_sg_ids}"

  tags {
    Name = "bsd-${count.index}"
  }
}

resource "aws_route53_record" "bsd" {
  count   = "${var.aws_number}"
  zone_id = "${var.dns_zone_id}"
  name    = "bsd-${count.index}.evlab.ch"
  type    = "A"
  ttl     = "300"
  records = ["${element(aws_instance.bsd.*.private_ip, count.index)}"]
}

# resource "aws_route53_record" "bsd-v6" {
#   count   = "${var.aws_number}"
#   zone_id = "${var.dns_zone_id}"
#   name    = "bsd-${count.index}.evlab.ch"
#   type    = "AAAA"
#   ttl     = "300"
#   records = ["${aws_instance.bsd.*.ipv6_addresses}"]
# }

