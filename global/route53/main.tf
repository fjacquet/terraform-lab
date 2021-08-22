resource "aws_route53_zone" "ezlab" {
  name = var.dns_suffix
  // vpc_id = "${var.aws_vpc_id}"

  tags = {
    Environment = "lab"
  }
}
