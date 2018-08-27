module "global" {
  source = "./global"
}

module "bsd" {
  source = "./bsd"
}

module "linux" {
  source = "./linux"
}

module "microsoft" {
  source = "./microsoft"
}

module "mgmt" {
  source = "./mgmt"
}

module "backup" {
  source = "./backup"
}

resource "aws_key_pair" "auth" {
  key_name   = "${var.key_name}"
  public_key = "${var.public_key}"
}
