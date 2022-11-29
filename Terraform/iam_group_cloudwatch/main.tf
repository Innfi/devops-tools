# provide a basic read access policy for cloudwatch via iam group

resource "aws_iam_group" "target_group" {
  name = "viewer_group"
}

resource "aws_iam_policy" "policy_cloudwatch_view" {
  name = "cloudwatch_view"

  policy = jsonencode({
    Statement = [
      {
        Action = [
          "cloudwatch:DescribeAlarms",
          "cloudwatch:GetMetricData",
          "cloudwatch:GetMetricStatistics",
          "cloudwatch:ListMetrics",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:FilterLogEvents",
          "logs:GetLogGroupFields",
          "logs:GetLogRecord",
          "logs:GetLogEvents",
          "logs:GetQueryResults",
          "logs:StartQuery",
        ],
        Effect = "Allow",
        Resource = "*",
      },
    ]
  })
}

resource "aws_iam_group_policy_attachment" "attach_policy_cloudwatch_view" {
  group = aws_iam_group.target_group.name
  policy_arn = ""
}

resource "aws_iam_user" "readonly_innfi" {
  name = "readonly_innfi"
}

resource "aws_iam_user" "readonly_ennfi" {
  name = "readonly_ennfi"
}

resource "aws_iam_user" "users" {
  for_each = var.user_names

  name = each.key
}

# TODO: provide user list as array

resource "aws_iam_group_membership" "target_group_membership" {
  name = "view_group_membership"

  for_each = var.user_names

  users = each.key

  group = aws_iam_group.target_group.name
}