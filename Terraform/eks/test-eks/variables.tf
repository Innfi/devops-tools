# Input variable definitions 

variable "azs" {
  description = "availability zones" 
  type = list
}

variable "name" {
  description = "Name to be used on all the resources as identifier"
  type        = string
  default     = ""
}

variable "cluster_name" {
  description = "k8s cluster name"
  type        = string
  default     = "eks_innfi"
}

variable "cidr" {
  description = "vpc cidr"
  type        = string
}

variable "subnet_public" {
  description = "public subnet cidrs"
  type = list
}
