output "aws_sg_master_ids" {
  value = aws_security_group.master.*.id
}

output "aws_sg_client_ids" {
  value = aws_security_group.client.*.id
}
