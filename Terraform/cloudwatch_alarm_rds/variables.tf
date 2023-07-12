variable "instanceid" {
  description = "RDS instance id" 
  type = string
}

variable "alarm-sqs-arn" {
  description = "sqs arn for alarm"
  type = string
}