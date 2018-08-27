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
