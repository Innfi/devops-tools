variable "subnets" {
  type = list(string)
}

variable "security_group_ids" {
  type = list(number)
}

variable "cloudwatch_log_group_name" {
  type = string
}

variable "kinesis_firehose_stream_name" {
  type = string
}

variable "s3_bucket_id" {
  type = string
}