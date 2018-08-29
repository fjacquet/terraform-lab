# Amazon access
provider "aws" {
  access_key = "${var.access_key}"
  region     = "${var.aws_region}"
  secret_key = "${var.secret_key}"
}

# backend to store lock file
terraform {
  backend "s3" {
    encrypt        = true
    bucket         = "tf-config"
    dynamodb_table = "terraform-state-lock-dynamo"
    region         = "eu-west-1"
    key            = "evlab/terraform.tfstate"
  }
}

resource "aws_key_pair" "auth" {
  key_name   = "${var.key_name}"
  public_key = "${var.public_key}"
}
