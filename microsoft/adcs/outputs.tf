output "aws_sg_pki-crl_id" {
  value = "${aws_security_group.pki-crl.id}"
}

output "aws_sg_pki-ica_id" {
  value = "${aws_security_group.pki-ica.id}"
}

output "aws_sg_pki-rca_id" {
  value = "${aws_security_group.pki-rca.id}"
}
