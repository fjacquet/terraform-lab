resource "aws_route53_zone" "evlab" {
  name   = "evlab.ch."
  vpc_id = "${var.aws_vpc_id}"

  tags {
    Environment = "lab"
  }
}