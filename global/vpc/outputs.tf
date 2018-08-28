output "aws_vpc_id" {
   value = "${aws_vpc.evlab.id}"
}

output "aws_subnet_back_id" {
   value = "${aws_subnet.back.id}"
}
output "aws_subnet_web_id" {
   value = "${aws_subnet.web.id}"
}
output "aws_subnet_exch_id" {
   value = "${aws_subnet.exch.id}"
}
output "aws_subnet_mgmt_id" {
   value = "${aws_subnet.mgmt.id}"
}
