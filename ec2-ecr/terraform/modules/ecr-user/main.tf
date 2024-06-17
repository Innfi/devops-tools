resource "aws_iam_user" "starter_user" {
  name = "starter"
}

resource "aws_iam_user_policy" "policy_baseline" {
  name = "policy-baseline"
  user = aws_iam_user.starter_user.name

  policy = jsonencode({
    Statement = [
      {
        Action = [
          "ecr:GetAuthorizationToken",
        ],
        Effect = "Allow",
        Resource = "*"
      },
      {
        Action = [
          "ecr:BatchGetImage",
          "ecr:DescribeRegistry",
          "ecr:GetRepositoryPolicy",
          "ecr:GetLifecyclePolicy",
          "ecr:GetRepositoryPolicy",
          "ecr:GetRegistryScanningConfiguration",
          "ecr:GetRegistryPolicy",
          "ecr:GetDownloadUrlForLayer",
        ],
        Effect = "Allow"
        Resource = var.ecr_arn
      }
    ]
  })
}


