variable "source_account_ids" {
  description = "List of AWS account IDs that will send logs"
  type        = list(string)
  default     = ["111111111111", "222222222222"]
}

variable "central_account_id" {
  description = "Central logging account ID"
  type        = string
}

# S3 bucket for aggregated logs
resource "aws_s3_bucket" "central_logs" {
  bucket = "central-logs-${var.central_account_id}"
}

resource "aws_s3_bucket_versioning" "central_logs" {
  bucket = aws_s3_bucket.central_logs.id
 
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "central_logs" {
  bucket = aws_s3_bucket.central_logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "central_logs" {
  bucket = aws_s3_bucket.central_logs.id

  rule {
    id     = "archive-old-logs"
    status = "Enabled"

    transition {
      days          = 90
      storage_class = "GLACIER"
    }

    expiration {
      days = 365
    }
  }
}

# IAM role for Firehose
resource "aws_iam_role" "firehose_role" {
  name = "central-logs-firehose-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "firehose.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "firehose_s3_policy" {
  name = "firehose-s3-policy"
  role = aws_iam_role.firehose_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:AbortMultipartUpload",
          "s3:GetBucketLocation",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:ListBucketMultipartUploads",
          "s3:PutObject"
        ]
        Resource = [
          aws_s3_bucket.central_logs.arn,
          "${aws_s3_bucket.central_logs.arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "logs:PutLogEvents"
        ]
        Resource = [
          aws_cloudwatch_log_group.firehose_logs.arn
        ]
      }
    ]
  })
}

# CloudWatch log group for Firehose delivery errors
resource "aws_cloudwatch_log_group" "firehose_logs" {
  name              = "/aws/kinesisfirehose/central-logs"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_stream" "firehose_log_stream" {
  name           = "S3Delivery"
  log_group_name = aws_cloudwatch_log_group.firehose_logs.name
}

# Kinesis Firehose delivery stream
resource "aws_kinesis_firehose_delivery_stream" "central_logs" {
  name        = "central-logs-stream"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn   = aws_iam_role.firehose_role.arn
    bucket_arn = aws_s3_bucket.central_logs.arn
   
    prefix              = "logs/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/"
    error_output_prefix = "errors/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/!{firehose:error-output-type}/"
   
    buffering_size     = 5
    buffering_interval = 300
    compression_format = "GZIP"

    cloudwatch_logging_options {
      enabled         = true
      log_group_name  = aws_cloudwatch_log_group.firehose_logs.name
      log_stream_name = aws_cloudwatch_log_stream.firehose_log_stream.name
    }
  }
}

# IAM role for CloudWatch Logs destination
resource "aws_iam_role" "cloudwatch_logs_destination_role" {
  name = "cloudwatch-logs-destination-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "logs.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "cloudwatch_logs_firehose_policy" {
  name = "cloudwatch-logs-firehose-policy"
  role = aws_iam_role.cloudwatch_logs_destination_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "firehose:PutRecord",
          "firehose:PutRecordBatch"
        ]
        Resource = aws_kinesis_firehose_delivery_stream.central_logs.arn
      }
    ]
  })
}

# CloudWatch Logs destination
resource "aws_cloudwatch_log_destination" "central_logs" {
  name       = "CentralLogsDestination"
  role_arn   = aws_iam_role.cloudwatch_logs_destination_role.arn
  target_arn = aws_kinesis_firehose_delivery_stream.central_logs.arn
}

# Destination policy allowing source accounts
resource "aws_cloudwatch_log_destination_policy" "central_logs" {
  destination_name = aws_cloudwatch_log_destination.central_logs.name
 
  access_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowSourceAccounts"
        Effect = "Allow"
        Principal = {
          AWS = [for account_id in var.source_account_ids : "arn:aws:iam::${account_id}:root"]
        }
        Action = [
          "logs:PutSubscriptionFilter"
        ]
        Resource = aws_cloudwatch_log_destination.central_logs.arn
      }
    ]
  })
}

# Outputs
output "destination_arn" {
  description = "ARN of the CloudWatch Logs destination"
  value       = aws_cloudwatch_log_destination.central_logs.arn
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket for aggregated logs"
  value       = aws_s3_bucket.central_logs.id
}