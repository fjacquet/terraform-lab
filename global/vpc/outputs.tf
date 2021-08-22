output "aws_vpc_id" {
  value = aws_vpc.ezlab.id
}

output "vpc_cidr" {
  value = aws_vpc.ezlab.cidr_block
}

output "aws_subnet_back_id" {
  value = aws_subnet.back.*.id
}

output "aws_subnet_backup_id" {
  value = aws_subnet.backup.*.id
}

output "aws_subnet_web_id" {
  value = aws_subnet.web.*.id
}

output "aws_subnet_exchange_id" {
  value = aws_subnet.exchange.*.id
}

output "aws_subnet_mgmt_id" {
  value = aws_subnet.mgmt.*.id
}
