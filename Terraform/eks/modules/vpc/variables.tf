# Input variable definitions 

variable "azs" {
  description = "availability zones" 
  type = list
}

variable "name" {
  description = "Name to be used on all the resources as identifier"
  type = string
  default = ""
}

variable "cluster_name" {
  description = "k8s cluster name"
  type = string
}

variable "cidr" {
  description = "vpc cidr"
  type = string
}

variable "subnet_public" {
  description = "public subnet cidrs"
  type = list
}

variable "subnet_private" {
  description = "private subnet cidrs"
  type = list
}

variable "from_port" {
  description = "start port for security group"
  type = number
}

variable "to_port" {
  description = "end port for security group"
  type = number
}

variable "internal_cidrs" {
  description = "allowed cidrs to connect"
  type = list(string)
}