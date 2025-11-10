terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Temporarily disabled due to template provider compatibility issue on Apple Silicon
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

  default_tags {
    tags = {
      Project     = "terraform-lab"
      ManagedBy   = "Terraform"
      Environment = "lab"
      Repository  = "github.com/fjacquet/terraform-lab"
    }
  }
}

data "aws_s3_bucket" "tf-config" {
  bucket = "tf-config"
}

resource "aws_key_pair" "auth" {
  key_name   = var.key_name
  public_key = var.public_key
}
