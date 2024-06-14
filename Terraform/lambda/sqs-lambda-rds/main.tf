module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "test-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["ap-northeast-2a", "ap-northeast-2b", "ap-northeast-2c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  enable_dns_hostnames = true

  tags = {
    Terraform = "true"
  }
}

resource "aws_db_instance" "dest_db" {
  db_name = "dest_db"
  engine = "mysql"
  engine_version = "5.8"
  instance_class = "db.t4g.medium"
  parameter_group_name = "default.mysql5.8"
  username = "innfi"
  password = "test"
  multi_az = true
}

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
          "sqs:GetQueueUrl",
          "sqs:GetQueueAttributes",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
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
  # filename = "artifact.zip"
  function_name = "subscriber"
  role = aws_iam_role.subscriber-role.arn
  runtime = "nodejs18.x"
  architectures = ["arm64"]

  s3_bucket = "test_bucket"
  s3_key = "artifact.zip" // funtion is not updated by s3 object upload. what to do?

  vpc_config {
    subnet_ids = module.vpc.intra_subnets[*].id
    security_group_ids = [data.security_group_id]
  }

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