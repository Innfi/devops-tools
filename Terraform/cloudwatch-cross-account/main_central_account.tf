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
    ]
    resources = [
      aws_oam_sink.central_sink.id
    ]
  }
}

resource "aws_oam_sink_policy" "central_sink_policy" {
  sink_identifier = aws_oam_sink.central_sink.id
  policy = data.aws_iam_policy_document.sink_policy.json
}