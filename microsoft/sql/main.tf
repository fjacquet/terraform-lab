resource "aws_route53_record" "sql" {
  count   = var.aws_number
  zone_id = var.dns_zone_id
  name    = "sql-${count.index}.${var.dns_suffix}"
  type    = "A"
  ttl     = "300"
  records = [element(aws_instance.sql.*.private_ip, count.index)]
}

# resource "aws_route53_record" "sql-v6" {
#   count   = "${var.aws_number}"
#   zone_id = "${var.dns_zone_id}"
#   name    = "sql-${count.index}.${var.dns_suffix}"
#   type    = "AAAA"
#   ttl     = "300"
#   records = ["${aws_instance.sql.*.ipv6_addresses}"]
# }

resource "aws_instance" "sql" {
  ami                  = var.aws_ami
  availability_zone    = element(var.azs, count.index)
  count                = var.aws_number
  ebs_optimized        = "true"
  iam_instance_profile = var.aws_iip_assumerole_name
  instance_type        = "m4.large"
  ipv6_address_count   = 1
  key_name             = var.aws_key_pair_auth_id
  subnet_id            = var.aws_subnet_id
  user_data            = file("user_data/config-sql.ps1")

  lifecycle {
    ignore_changes = [user_data]
  }

  tags = {
    Name        = "sql-${count.index}"
    Environment = "lab"
  }

  # Our Security group to allow RDP access
  vpc_security_group_ids = var.aws_sg_ids
}

resource "aws_security_group" "sql" {
  name        = "tf_evlab_sql"
  description = "Used in the terraform"
  vpc_id      = var.aws_vpc_id

  # HTTP access from anywhere
  ingress {
    from_port = 1433
    to_port   = 1433
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

  ingress {
    from_port = 5022
    to_port   = 5022
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

