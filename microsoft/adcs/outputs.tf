output "aws_sg_pki-crl_id" {
  value = aws_security_group.pki-crl[count.index].id
}

output "aws_sg_pki-ica_id" {
  value = aws_security_group.pki-ica[count.index].id
}

output "aws_sg_pki-rca_id" {
  value = aws_security_group.pki-rca[count.index].id
}

