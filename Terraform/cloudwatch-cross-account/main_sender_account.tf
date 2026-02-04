resource "aws_oam_link" "central_link" {
  sink_identifier = var.sink_arn
  label_template = "$AccountName - $ResourceName"
  resource_types = [
    "AWS::Logs::LogGroup"
  ]
}
