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
  name         = var.dns_suffix
  private_zone = false
  // vpc_id = "${var.aws_vpc_id}"
  tags = {
    Environment = "lab"
  }

}
