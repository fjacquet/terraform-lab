output "dc_private_ip" {
  description = "description"
  value       = "${aws_instance.dc.*.private_ip}"
}

output "aws_sg_dc_id" {
  value = "${aws_security_group.dc.id}"
}
