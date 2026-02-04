resource "aws_oam_sink" "central_sink" {
  name = "CentralMonitoringSink"
}

data "aws_iam_policy_document" "sink_policy" {
  statement {
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = [ "123456", "2345667" ]
    }
    actions = [
        "oam:CreateLink",
        "oam:UpdateLink",
        "logs:SearchLogGroups",
        "logs:ListLogGroups",
        "logs:DescribeLogGroups",
        "logs:GetLogGroupFields",
        "logs:FilterLogEvents",
        "logs:GetLogEvents",
        "logs:StartQuery",
        "logs:StopQuery",
        "logs:GetQueryResults",
        "logs:ListTagsForResource",
        // optional: xray
    ]
    resources = [
      "arn:aws:oam:*:*:sink/${aws_oam_sink.central_sink.id}"
    ]
  }
}

resource "aws_oam_sink_policy" "central_sink_policy" {
  sink_identifier = aws_oam_sink.central_sink.id
  policy = data.aws_iam_policy_document.sink_policy.json
}