resource "aws_sns_topic" "sns_alarm" {
  name = "sns-alarm"
}

resource "aws_sns_topic_subscription" "sub_sns_alarm" {
  topic_arn = aws_sns_topic.sns_alarm.arn

  protocol = "sqs" #email is unsupported because of its interactive procedure
  endpoint = var.alarm-sqs-arn

}

resource "aws_cloudwatch_metric_alarm" "rds_alarm" {
  alarm_name                = "rds-alarm-cpu"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 2
  threshold                 = 50
  alarm_description         = "CPU usage has exceeded 50%"
  alarm_actions = [
    var.alarm-sns-arn
  ]

  insufficient_data_actions = []

  metric_name = "CPUUtilization"
  namespace = "AWS/RDS"
  period = 120
  statistic = "Average"

  dimensions = {
    # DBClusterIdentifier = var.
    DBClusterIdentifier = var.instanceid
  }
}