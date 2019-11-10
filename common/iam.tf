resource "aws_iam_group" "developers" {
  name = "Developers"
}

resource "aws_iam_group" "cloud" {
  name = "Cloud"
}

data "aws_iam_policy_document" "ec2instancerole_assume_role_policy" {
  statement {
    actions = [ "sts:AssumeRole" ]
    principals {
      type = "Service"
      identifiers = [ "ec2.amazonaws.com" ]
    }
  }
}

data "aws_iam_policy_document" "s3_shared_access" {
  statement {
    effect = "Allow"
    actions = [
      "s3:Get*",
      "s3:List*"
    ]
    resources = ["arn:aws:s3:::"]
  }
  statement {
    effect = "Allow"
    actions = ["s3:*"]
    resources = [
      "arn:aws:s3:::shared-storage-s3",
      "arn:aws:s3:::shared-storage-s3/*"
      ]
  }
}

resource "aws_iam_role" "instance_role" {
  name = "ec2InstanceRole"
  assume_role_policy = "${data.aws_iam_policy_document.ec2instancerole_assume_role_policy.json}"
}

resource "aws_iam_role_policy" "s3_shared_access" {
  name = "S3_shared_access"
  # description = "S3 policy to attach to EC2 instances"
  role = "${aws_iam_role.instance_role.id}"
  policy = "${data.aws_iam_policy_document.s3_shared_access.json}"
}

resource "aws_iam_instance_profile" "instance" {
	name = "ec2InstanceRole"
  # description = "Allows EC2 instances to call AWS services on your behalf."
	role = "${aws_iam_role.instance_role.id}"
}