# EKS alarm

resource "aws_cloudwatch_metric_alarm" "alarm" {
  for_each = {for i, v in var.input: i => v}

  alarm_name = each.value.name
  metric_name = "pod_cpu_utilization"
  namespace = "ContainerInsights"

  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = 1
  threshold = each.value.threshold
  period = 60
  statistic = "Average"

  dimensions = {
    Namespace = "default"
    ClusterName = "initial"
    PodName = each.value.pod
  }

  alarm_description = each.value.desc
  alarm_actions = [
    var.action_arn
  ]
}

# RDS alarm

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
    DBClusterIdentifier = var.instance-id
  }
}

# EC2 CPU alarm

resource "aws_cloudwatch_metric_alarm" "service-alarm-cpu" {
  alarm_name = "cpu_alarm"
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"

  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = 1
  threshold = 30
  period = 300
  statistic = "Average"

  alarm_description = "cpu check"
  alarm_actions = [
    var.alarm-sns-arn
  ]

  dimensions = {
    InstanceId = var.ec2-instance-id
  }
}

resource "aws_cloudwatch_metric_alarm" "service-alarm-status-chedk" {
  alarm_name = "healthcheck"
  metric_name = "StatusCheckFailed"
  namespace = "AWS/EC2"

  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = 1
  threshold = "0.99"
  period = 300
  statistic = "Maximum"

  alarm_description = "healthcheck"
  alarm_actions = [
    var.alarm-sns-arn
  ]

  dimensions = {
    InstanceId = var.ec2-instance-id
  }
}