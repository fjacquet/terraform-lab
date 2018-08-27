data "aws_s3_bucket" "tf-config" {
  bucket = "tf-config"
}

data "aws_s3_bucket" "installer-fja" {
  bucket = "installer-fja"
}