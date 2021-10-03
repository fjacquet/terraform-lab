terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
  backend "remote" {
    organization = "fjacquet"

    workspaces {
      name = "terraform-lab"
    }
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
