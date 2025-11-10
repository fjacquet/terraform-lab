resource "aws_route53_zone" "ezlab" {
  name = var.dns_suffix
  // vpc_id = "${var.aws_vpc_id}"
  vpc {
    vpc_id = var.aws_vpc_id
  }

  tags = {
    Environment = "lab"
  }
}

data "aws_route53_zone" "ezlab-public" {
  count        = var.public_dns_id != "" ? 1 : 0
  zone_id      = var.public_dns_id
  private_zone = false
}
