variable "central_destination_arn" {
  description = "ARN of the CloudWatch Logs destination in central account"
  type        = string
}

variable "log_groups" {
  description = "Map of log groups to create subscription filters for"
  type = map(object({
    name           = string
    filter_pattern = string
  }))
  default = {
    lambda = {
      name           = "/aws/lambda/my-function"
      filter_pattern = ""
    }
    ecs = {
      name           = "/aws/ecs/my-service"
      filter_pattern = ""
    }
  }
}

# IAM role for subscription filter
resource "aws_iam_role" "subscription_filter_role" {
  name = "cloudwatch-subscription-filter-role"

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

resource "aws_iam_role_policy" "subscription_filter_policy" {
  name = "subscription-filter-policy"
  role = aws_iam_role.subscription_filter_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:PutLogEvents"
        ]
        Resource = var.central_destination_arn
      }
    ]
  })
}

# Create subscription filters for each log group
resource "aws_cloudwatch_log_subscription_filter" "central_logs" {
  for_each = var.log_groups

  name            = "central-logs-${each.key}"
  log_group_name  = each.value.name
  filter_pattern  = each.value.filter_pattern
  destination_arn = var.central_destination_arn
 
  # Optional: only if you need cross-account IAM role
  # role_arn = aws_iam_role.subscription_filter_role.arn

  depends_on = [aws_iam_role_policy.subscription_filter_policy]
}

# Example: Create a log group if it doesn't exist
resource "aws_cloudwatch_log_group" "example" {
  for_each = var.log_groups

  name              = each.value.name
  retention_in_days = 7
}

# CloudWatch alarms for Firehose
resource "aws_cloudwatch_metric_alarm" "firehose_delivery_errors" {
  alarm_name          = "firehose-delivery-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "DeliveryToS3.DataFreshness"
  namespace           = "AWS/Firehose"
  period              = 300
  statistic           = "Maximum"
  threshold           = 900
  alarm_description   = "Firehose delivery is delayed"
 
  dimensions = {
    DeliveryStreamName = aws_kinesis_firehose_delivery_stream.central_logs.name
  }
}
