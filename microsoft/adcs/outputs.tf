output "aws_sg_pki_crl_id" {
  value = "${aws_security_group.pki_crl.id}"
}

output "aws_sg_pki_ica_id" {
  value = "${aws_security_group.pki_ica.id}"
}

output "aws_sg_pki_rca_id" {
  value = "${aws_security_group.pki_rca.id}"
}
