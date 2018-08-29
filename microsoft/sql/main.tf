resource "aws_instance" "sql" {
  instance_type        = "m4.large"
  count                = "${var.aws_number}"
  availability_zone    = "${element(var.azs, count.index)}"
  iam_instance_profile = "${var.aws_iip_assumerole_name}"
  ami                  = "${lookup(var.aws_amis, var.aws_region)}"
  subnet_id            = "${var.aws_subnet_id}"
  key_name             = "${var.aws_key_pair_auth_id}"
  ebs_optimized        = "true"
  user_data            = "${file("user_data/config-sql.ps1")}"

  lifecycle {
    ignore_changes = ["user_data"]
  }

  tags {
    Name = "sql-${count.index}"
  }

  # Our Security group to allow RDP access
  vpc_security_group_ids = [
    "${var.aws_sg_ids}",
  ]
}

resource "aws_security_group" "sql" {
  name        = "terraform_evlab_sql"
  description = "Used in the terraform"
  vpc_id      = "${var.aws_vpc_id}"

  # HTTP access from anywhere
  ingress {
    from_port   = 1433
    to_port     = 1433
    protocol    = "tcp"
    cidr_blocks = ["${element(var.cidr, count.index)}"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}