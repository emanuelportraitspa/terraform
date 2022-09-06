resource "aws_iam_user" "emanuelpozarnik" {
  name = "EmanuelPozarnik"
  path = "/"

  tags = {
    tag-key = "Emanuel"
  }
}

resource "aws_iam_access_key" "emanuelpozarnik" {
  user = aws_iam_user.emanuelpozarnik.name
}

resource "aws_iam_user_policy" "devops" {
  name = "DevOps"
  user = aws_iam_user.emanuelpozarnik

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:Describe*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}
