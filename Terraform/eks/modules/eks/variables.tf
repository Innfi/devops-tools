# Input variable definitions

variable "vpc_id" {
  description = "vpc id for eks"
  type = string
}

variable "subnet_id_public" {
  description = "public subnet id"
  type = list
}

variable "cluster_name" {
  description = "k8s cluster name"
  type = string
}

output "sg_id_public" {
  description = "public security group id"
}