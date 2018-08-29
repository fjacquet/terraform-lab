resource "aws_iam_policy" "ec2s3access" {
  name        = "ec2s3access"
  description = "ec2 can access s3 install"
  policy      = "${file("./iam_json/iam-policy-s3access.json")}"
}

resource "aws_iam_policy" "ec2ro" {
  name        = "ec2ro"
  description = "ec2 can access ec2 read only"
  policy      = "${file("./iam_json/iam-policy-ec2ro.json")}"
}

resource "aws_iam_policy_attachment" "assumerole-ec2ro-attach" {
  name       = "assumerole-ec2ro-attach"
  roles      = ["${aws_iam_role.assumerole.name}"]
  policy_arn = "${aws_iam_policy.ec2ro.arn}"
}

resource "aws_iam_policy_attachment" "assumerole-ec2s3access-attach" {
  name       = "assumerole-ec2s3access-attach"
  roles      = ["${aws_iam_role.assumerole.name}"]
  policy_arn = "${aws_iam_policy.ec2s3access.arn}"
}

resource "aws_iam_instance_profile" "aws_iip_assumerole" {
  name = "aws_iip_aws_iip_assumerole"
  role = "${aws_iam_role.assumerole.name}"
}

resource "aws_iam_role" "assumerole" {
  name               = "assumerole"
  assume_role_policy = "${file("./iam_json/iam-role-assure-role.json")}"
}
