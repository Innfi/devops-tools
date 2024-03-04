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