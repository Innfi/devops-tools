resource "aws_iam_policy" "policy_devops" {
    name = "policy_devops" 
    path = "/"
    description = "policy for pipeline"

    policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "codedeploy:*",
                "codecommit:*",
                "codepipeline:*",
                "s3:*"
            ],
            "Effect": "Allow",
            "Resource": "*"
        }
    ]
}
EOF
}

data "aws_iam_user" "InnfisDev" {
    user_name = "InnfisDev"
}

resource "aws_iam_user_policy_attachment" "attach-devops" {
    user = data.aws_iam_user.InnfisDev.user_name
    policy_arn = aws_iam_policy.policy_devops.arn
}