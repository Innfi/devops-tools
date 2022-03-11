# Input variable definitions 

variable "vpc_name" {
    description = "Name of VPC"
    type = string 
    default = "test-eks"
}

variable "vpc_cidr" {
  description = "VPC CIDR blocks"
  type = string 
  default = "10.0.0.0/16"
}

variable "vpc_azs" {
  description = "AZs"
  type = list 
  default = [
    "ap-northeast-2a",
    "ap-northeast-2c"
  ]
}

variable "vpc_public_subnets" {
  description = "Public Subnets"
  type = list(string) 
  default = [
    "10.0.1.0/24",
    "10.0.2.0/24"
  ]
}

variable "from_port" {
  description = "start port for security group"
  type = number
  default = 443
}

variable "to_port" {
  description = "end port for security group"
  type = number
  default = 443
}

variable "internal_cidrs" {
  description = "allowed cidrs to connect"
  type = list(string)
  default = ["0.0.0.0/0"]
}

variable "cluster_name" {
  description = "k8s cluster name"
  type = string
  default = "eks_innfi"
}
