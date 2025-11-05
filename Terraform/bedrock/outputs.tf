output "bedrock_log_group_name" {
  description = "Name of the CloudWatch Log Group for Bedrock"
  value       = aws_cloudwatch_log_group.bedrock.name
}

output "bedrock_log_group_arn" {
  description = "ARN of the CloudWatch Log Group for Bedrock"
  value       = aws_cloudwatch_log_group.bedrock.arn
}

output "bedrock_logs_bucket_name" {
  description = "Name of the S3 bucket for Bedrock logs"
  value       = aws_s3_bucket.bedrock_logs.id
}

output "bedrock_logs_bucket_arn" {
  description = "ARN of the S3 bucket for Bedrock logs"
  value       = aws_s3_bucket.bedrock_logs.arn
}

output "bedrock_logging_role_arn" {
  description = "ARN of the IAM role for Bedrock logging"
  value       = aws_iam_role.bedrock_logging.arn
}
