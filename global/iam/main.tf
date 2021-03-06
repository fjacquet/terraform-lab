resource "aws_iam_instance_profile" "aws_iip_assumerole" {
  name = "aws_iip_assumerole-${var.aws_vpc_id}"
  role = aws_iam_role.assumerole.name
}

resource "aws_iam_role" "assumerole" {
  name               = "assumerole-${var.aws_vpc_id}"
  assume_role_policy = file("./policy_json/iam-role-assume-role.json")
}

resource "aws_iam_policy" "ec2s3access" {
  name        = "ec2s3access-${var.aws_vpc_id}"
  description = "ec2 can access s3 install"
  policy      = file("./policy_json/iam-policy-s3access.json")
}

resource "aws_iam_policy" "ec2getsecret" {
  name        = "getsecret-${var.aws_vpc_id}"
  description = "ec2 can access secretes"
  policy      = file("./policy_json/iam-policy-getsecret.json")
}

resource "aws_iam_policy" "ec2ro" {
  name        = "ec2ro-${var.aws_vpc_id}"
  description = "ec2 can access ec2 read only"
  policy      = file("./policy_json/iam-policy-ec2ro.json")
}

resource "aws_iam_policy_attachment" "assumerole-ec2ro-attach" {
  name       = "assumerole-ec2ro-attach"
  roles      = [aws_iam_role.assumerole.name]
  policy_arn = aws_iam_policy.ec2ro.arn
}

resource "aws_iam_policy_attachment" "assumerole-getsecret-attach" {
  name       = "assumerole-getsecret-attach"
  roles      = [aws_iam_role.assumerole.name]
  policy_arn = aws_iam_policy.ec2getsecret.arn
}

resource "aws_iam_policy_attachment" "assumerole-ec2s3access-attach" {
  name       = "assumerole-ec2s3access-attach"
  roles      = [aws_iam_role.assumerole.name]
  policy_arn = aws_iam_policy.ec2s3access.arn
}

