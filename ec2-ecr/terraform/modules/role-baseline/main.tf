resource "aws_iam_policy" "policy_baseline" {
  name = "policy-baseline"

  policy = jsonencode({
    Statement = [
      {
        Action = [
          "ecr:BatchGetImage",
          "ecr:DescribeRegistry",
          "ecr:GetAuthorizationToken",
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

resource "aws_iam_role" "role_baseline" {
  name = "role-baseline"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "policy_attachment" {
  role = aws_iam_role.role_baseline.name
  policy_arn = aws_iam_policy.policy_baseline.arn
}