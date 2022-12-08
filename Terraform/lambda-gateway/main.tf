resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda_exec_role" 

  assume_role_policy = jsonencode({
    Statement = [
      {
        Action = ["sts:AssumeRole"],
        Principal = {
          Service = "lambda.amazonaws.com"
        },
        Effect = "Allow",
      }
    ]
  })
}

resource "aws_lambda_function" "innfis_func" {
  function_name = "innfis_func"
  role = aws_iam_role.lambda_exec_role.arn

  package_type = "Image"
  image_url = "to_be_added"
}