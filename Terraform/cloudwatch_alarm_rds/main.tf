resource "aws_cloudwatch_metric_alarm" "rds_alarm" {
  alarm_name                = "terraform-test-foobar"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 2
  threshold                 = 50
  alarm_description         = "Request error rate has exceeded 50%"
  insufficient_data_actions = []

  metric_query {
    id = "metric_cpu"

    metric {
      metric_name = "RDSCPU"
      namespace   = "AWS/RDS"
      period      = 120
      stat        = "Sum"
      unit        = "Count"

      dimensions = {
        # DBClusterIdentifier = var.
        DBClusterIdentifier = var.instanceid
      }
    }
  }
}