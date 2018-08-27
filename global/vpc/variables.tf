variable "azs" {
  description = "AWS availability zone to launch servers."
  type        = "list"
  default     = ["eu-west-1a", "eu-west-1b"]
}


variable "aws_region" {
  type    = "string"
  default = "eu-west-1"
}
