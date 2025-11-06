terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# AWS Bedrock Foundation Model
resource "aws_bedrock_model_invocation_logging_configuration" "main" {
  logging_config {
    embedding_data_delivery_enabled = var.enable_embedding_data_delivery
    image_data_delivery_enabled     = var.enable_image_data_delivery
    text_data_delivery_enabled      = var.enable_text_data_delivery

    cloudwatch_config {
      log_group_name = aws_cloudwatch_log_group.bedrock.name
      role_arn       = aws_iam_role.bedrock_logging.arn
    }

    s3_config {
      bucket_name = aws_s3_bucket.bedrock_logs.id
    }
  }
}

# CloudWatch Log Group for Bedrock
resource "aws_cloudwatch_log_group" "bedrock" {
  name              = "/aws/bedrock/${var.environment}"
  retention_in_days = var.log_retention_days
  
  tags = var.tags
}

# S3 Bucket for Bedrock Logs
resource "aws_s3_bucket" "bedrock_logs" {
  bucket = "${var.project_name}-bedrock-logs-${var.environment}"
  
  tags = var.tags
}

resource "aws_s3_bucket_versioning" "bedrock_logs" {
  bucket = aws_s3_bucket.bedrock_logs.id
  
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "bedrock_logs" {
  bucket = aws_s3_bucket.bedrock_logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# IAM Role for Bedrock Logging
resource "aws_iam_role" "bedrock_logging" {
  name = "${var.project_name}-bedrock-logging-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "bedrock.amazonaws.com"
        }
      }
    ]
  })
  
  tags = var.tags
}

# IAM Policy for Bedrock Logging
resource "aws_iam_role_policy" "bedrock_logging" {
  name = "${var.project_name}-bedrock-logging-policy"
  role = aws_iam_role.bedrock_logging.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "${aws_cloudwatch_log_group.bedrock.arn}:*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject"
        ]
        Resource = "${aws_s3_bucket.bedrock_logs.arn}/*"
      }
    ]
  })
}

resource "aws_bedrockagent_knowledge_base" "example" {
  name     = "example"
  role_arn = var.knowledge_base_role_arn
  knowledge_base_configuration {
    vector_knowledge_base_configuration {
      embedding_model_arn = var.embedding_model_arn
    }
    type = "VECTOR"
  }
  storage_configuration {
    # TODO: storage configuration
  }
}