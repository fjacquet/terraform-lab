  output "dc_private_ip" {
    description = "description"
    value       = "${aws_instance.dc.*.private_ip}"
  }