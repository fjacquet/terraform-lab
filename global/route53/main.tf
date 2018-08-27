resource "aws_route53_zone" "evlab" {
  name   = "evlab.ch."
  vpc_id = "${aws_vpc.evlab.id}"

  tags {
    Environment = "lab"
  }
}