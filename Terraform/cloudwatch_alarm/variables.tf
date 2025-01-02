# EKS alarm variables

variable "action_arn" {
  type = string
}

variable "input" {
  type = list(object({
    name = string 
    threshold = number 
    pod = string 
    desc = string
  }))

  default = [
    {
      name = "serviceAMetric"
      threshold = 90
      pod = "serviceA"
      desc = "service A cpu alarm"
    },
    {
      name = "serviceBMetric"
      threshold = 80
      pod = "serviceB"
      desc = "service B cpu alarm"
    }
  ]
}

# RDS alarm variables

variable "instance-id" {
  description = "RDS instance id" 
  type = string
}

variable "alarm-sqs-arn" {
  description = "sqs arn for alarm"
  type = string
}

variable "alarm-sns-arn" {
  description = "sns arn for alarm"
  type = string
}

# EC2 alarm

variable "ec2-instance-id" {
  description = "EC2 instance id" 
  type = string
}
