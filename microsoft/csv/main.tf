resource "aws_route53_record" "csv" {
  count   = "${var.aws_number}"
  zone_id = "${var.dns_zone_id}"
  name    = "csv-${count.index}.${var.dns_suffix}"
  type    = "A"
  ttl     = "300"
  records = ["${element(aws_instance.csv.*.private_ip, count.index)}"]
}

# resource "aws_route53_record" "fs-v6" {
#   count   = "${var.aws_number}"
#   zone_id = "${var.dns_zone_id}"
#   name    = "fs-${count.index}.${var.dns_suffix}"
#   type    = "AAAA"
#   ttl     = "300"
#   records = ["${aws_instance.fs.*.ipv6_addresses}"]
# }

resource "aws_instance" "csv" {
  ami                  = "${var.aws_ami}"
  availability_zone    = "${element(var.azs, count.index)}"
  count                = "${var.aws_number}"
  iam_instance_profile = "${var.aws_iip_assumerole_name}"
  instance_type        = "t3.medium"
  ipv6_address_count   = 1
  key_name             = "${var.aws_key_pair_auth_id}"
  subnet_id            = "${element(var.aws_subnet_id, count.index)}"
  user_data            = "${file("user_data/config-csv.ps1")}"

  tags {
    Name        = "csv-${count.index}"
    Environment = "lab"
  }

  lifecycle {
    ignore_changes = ["user_data"]
  }

  # Our Security group to allow RDP access
  vpc_security_group_ids = [
    "${var.aws_sg_ids}",
  ]
}

resource "aws_volume_attachment" "ebs_csv_cache" {
  device_name = "/dev/xvdb"
  count       = "${var.aws_number}"
  volume_id   = "${element(aws_ebs_volume.ssd.*.id, count.index)}"
  instance_id = "${element(aws_instance.csv.*.id, count.index)}"
}

resource "aws_ebs_volume" "ssd" {
  count             = "${var.aws_number}"
  availability_zone = "${element(var.azs, count.index)}"

  size = 100
  type = "gp2"
}

resource "aws_volume_attachment" "ebs_csv_data1" {
  device_name = "/dev/xvdc"
  count       = "${var.aws_number}"
  volume_id   = "${element(aws_ebs_volume.hdd1.*.id, count.index)}"
  instance_id = "${element(aws_instance.csv.*.id, count.index)}"
}

resource "aws_ebs_volume" "hdd1" {
  count             = "${var.aws_number}"
  availability_zone = "${element(var.azs, count.index)}"
  size              = 500
  type              = "st1"
}

resource "aws_volume_attachment" "ebs_csv_data2" {
  device_name = "/dev/xvdd"
  count       = "${var.aws_number}"
  volume_id   = "${element(aws_ebs_volume.hdd2.*.id, count.index)}"
  instance_id = "${element(aws_instance.csv.*.id, count.index)}"
}

resource "aws_ebs_volume" "hdd2" {
  count             = "${var.aws_number}"
  availability_zone = "${element(var.azs, count.index)}"
  size              = 500
  type              = "st1"
}

resource "aws_security_group" "csv" {
  name        = "csv"
  description = "Used in the terraform"
  vpc_id      = "${var.aws_vpc_id}"

  ingress {
    description     = "file Server"
    from_port       = 445
    to_port         = 445
    protocol        = "tcp"
    security_groups = ["${var.aws_sg_domain_members}"]
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
