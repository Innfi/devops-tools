variable "instanceid" {
  description = "RDS instance id" 
  type = string
}

variable "alarm-sns-arn" {
  description = "sns arn for alarm"
  type = string
}