resource "aws_iam_role" "codebuild_role" {
    name = "codebuild_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "codebuild_role_policy" {
    name = "codebuild_role_policy"
    role = aws_iam_role.codebuild_role.id

    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
      {
          "Action": [
              "codebuild:*",
              "s3:*"
          ],
          "Effect": "Allow",
          "Resource": "*"
      }
  ]
}
EOF
}