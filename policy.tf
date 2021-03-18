resource "aws_iam_role" "kops-role" {
  name = "kops-AssumeRole"
  tags = {
      Name = "AssumeRole"
  }

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "kops-policy" {
  name        = "kops-policy"
  description = "A policy for kops"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": ["ec2:*","iam:*","s3:*","route53:*","vpc:*","elasticloadbalancing:*","autoscaling:*","application-autoscaling:*"],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "kops-attach" {
  role       = aws_iam_role.kops-role.name
  policy_arn = aws_iam_policy.kops-policy.arn
}

resource "aws_iam_instance_profile" "kops-profile" {
  name     = "kops_instance_profile_name"
  role = aws_iam_role.kops-role.name
}