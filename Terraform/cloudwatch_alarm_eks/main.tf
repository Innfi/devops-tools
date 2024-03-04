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