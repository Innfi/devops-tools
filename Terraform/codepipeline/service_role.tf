resource "aws_iam_role" "codepipeline_role" {
  name = "codepipeline_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service" : [
          "codebuild.amazonaws.com",
          "codedeploy.amazonaws.com", 
          "codepipeline.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "codepipeline_role_policy" {
    name = "codepipeline_role_policy"
    role = aws_iam_role.codepipeline_role.id

    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
      {
        "Action": [
          "s3:*"
        ],
        "Effect": "Allow",
        "Resource": [
          "${aws_s3_bucket.ProjectMasterband.arn}",
          "${aws_s3_bucket.ProjectMasterband.arn}/*"
        ]
      },
      {
        "Action": [
          "codebuild:*",
          "codedeploy:*",
          "codepipeline:*"
        ],
        "Effect": "Allow",
        "Resource": "*"
      }
  ]
}
EOF
}
