resource "aws_iam_policy" "viewer_policy" {
  name = "Viewer"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AllowCloudwatchLogsInsight"
        Effect = "Allow",
        Action = [
          "logs:StartQuery",
          "logs:StopQuery",
          "logs:GetQueryResults",
          "logs:DescribeQueries",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:GetLogEvents",
          "logs:FilterLogEvents",
          "logs:PutQueryDefinition",
          "logs:DeleteQueryDefinition",
          "logs:DescribeQueryDefinitions",
          "oam:ListSinks",
          "oam:ListAttachedLinks",
          "oam:GetLink",
          "oam:GetSink",
          "cloudwatch:GetMetricData",
          "cloudwatch:ListMetrics",
        ],
        Resource = var.target_log_group_arns
      }
    ]
  })
}
