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
    type = "RDS"
    rds_configuration {
      resource_arn = var.vectordb_arn
      credentials_secret_arn = var.credentials_arn 
      database_name = "test-vectordb"
      table_name = "test-kb"
      field_mapping {
        primary_key_field = "id"
        vector_field = "embedding"
        text_field = "text"
        metadata_field = "metadata"
      }
    }
  }
}

resource "aws_bedrock_guardrail" "advanced" {
  name                      = "advanced-guardrail"
  blocked_input_messaging   = "This request cannot be processed."
  blocked_outputs_messaging = "This response cannot be provided."
  description               = "Advanced guardrail with multiple policies"

  # Content filters
  content_policy_config {
    filters_config {
      type            = "HATE"
      input_strength  = "HIGH"
      output_strength = "HIGH"
    }
    filters_config {
      type            = "VIOLENCE"
      input_strength  = "MEDIUM"
      output_strength = "HIGH"
    }
  }

  # Topic-based blocking
  topic_policy_config {
    topics_config {
      name       = "financial-advice"
      definition = "Providing specific investment or financial advice"
      examples   = ["Should I invest in stocks?", "What stocks should I buy?"]
      type       = "DENY"
    }
    topics_config {
      name       = "medical-diagnosis"
      definition = "Providing medical diagnoses or treatment recommendations"
      examples   = ["Do I have cancer?", "What medicine should I take?"]
      type       = "DENY"
    }
  }

  # Word filters (profanity, custom words)
  word_policy_config {
    managed_word_lists_config {
      type = "PROFANITY"
    }
    words_config {
      text = "confidential"
    }
    words_config {
      text = "internal-only"
    }
  }

  # Sensitive information filters (PII)
  sensitive_information_policy_config {
    pii_entities_config {
      action = "BLOCK"
      type   = "EMAIL"
    }
    pii_entities_config {
      action = "ANONYMIZE"
      type   = "PHONE"
    }
    pii_entities_config {
      action = "BLOCK"
      type   = "CREDIT_DEBIT_CARD_NUMBER"
    }
    pii_entities_config {
      action = "BLOCK"
      type   = "US_SOCIAL_SECURITY_NUMBER"
    }
  }

  tags = {
    Environment = "production"
    Team        = "platform"
  }
}