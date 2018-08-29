

variable "aws_key_pair_auth_id" {}
variable "aws_number" {}
variable "aws_region" {}
variable "aws_subnet_id" {}
variable "aws_amis" {
     type="map"
}
variable "aws_sg_ids" {
    type="list"
}
variable "azs" {
    type="list"
}