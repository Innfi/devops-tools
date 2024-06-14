resource "aws_ecr_repository" "source-repo" {
  name = "source-repo"
}

resource "aws_iam_policy" "lambda-policy" {
  name = "lambda-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect = "Allow"
        Resource = var.resource_arn
      }
    ]
  })
}

resource "aws_iam_role" "lambda-role" {
  name = "lambda-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda-role-attachment" {
  role = aws_iam_role.lambda-role.name
  policy_arn = aws_iam_policy.lambda-policy.arn
}

resource "aws_lambda_function" "function" {
  function_name = "test-function"

  role = aws_iam_role.lambda-role.arn

  package_type = "Image"
  image_uri = format("%s%s",
    aws_ecr_repository.source-repo.repository_url,
    var.tag_name
  )

  timeout = 60
  memory_size = 512
}

resource "aws_lambda_function_url" "function-url" {
  function_name = aws_lambda_function.function.name
  authorization_type = "NONE"
}