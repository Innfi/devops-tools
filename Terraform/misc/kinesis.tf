locals {
  nr_url = "https://(new relic url)"
}

resource "aws_kinesis_stream" "prod_stream" {
  name = "prod-stream"
  shard_count = 1
  retention_period = 24
}

resource "aws_kinesis_firehose_delivery_stream" "prod_delivery" {
  name = "prod-delivery"
  destination = "http_endpoint"

  http_endpoint_configuration {
    url = locals.nr_url
    role_arn = aws_iam_role.firehose.arn
    s3_configuration = {
      role_arn = aws_iam_role.firehose.arn
      bucket_arn = aws_s3_bucket.firehose_bucket.arn
      compression_format = "GZIP"
    }
  }
}