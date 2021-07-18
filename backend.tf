terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }

  backend "s3" {
    encrypt = true
    bucket  = "tf-config"
    # dynamodb_table = "terraform-state-lock-dynamo"
    region = "eu-west-1"
    key    = "evlab/terraform.tfstate"
  }
}

provider "aws" {
  access_key = var.access_key
  region     = var.aws_region
  secret_key = var.secret_key
}

data "aws_s3_bucket" "tf-config" {
  bucket = "tf-config"
}

resource "aws_key_pair" "auth" {
  key_name   = var.key_name
  public_key = var.public_key
}
