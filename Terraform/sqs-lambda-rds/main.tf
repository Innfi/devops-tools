resource "aws_sqs_queue" "publisher" {
  name = "publisher"
  delay_seconds = 10
}

resource "aws_iam_policy" "lambda-policy" {
  name = "lambda-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sqs:*",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role" "subscriber-role" {
  name = "subscriber-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Sid = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach-policy" {
  role = aws_iam_role.subscriber-role.name
  policy_arn = aws_iam_policy.lambda-policy.arn
}

resource "aws_lambda_function" "subscriber" {
  filename = "artifact.zip"
  function_name = "subscriber"
  role = aws_iam_role.subscriber-role.arn
  runtime = "nodejs18.x"
  architectures = ["arm64"]

  environment {
    variables = {
      "ENV_FIRST" = "first"
      "ENV_SECOND" = "second"
    }
  }
}

resource "aws_lambda_event_source_mapping" "pubsub-mapping" {
  event_source_arn = aws_sqs_queue.publisher.arn
  function_name = aws_lambda_function.subscriber.function_name
}