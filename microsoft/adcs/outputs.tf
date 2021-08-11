output "aws_sg_pki-crl_ids" {
  value = aws_security_group.pki-crl.*.id
}

output "aws_sg_pki-ica_ids" {
  value = aws_security_group.pki-ica.*.id
}

output "aws_sg_pki-rca_ids" {
  value = aws_security_group.pki-rca.*.id
}
