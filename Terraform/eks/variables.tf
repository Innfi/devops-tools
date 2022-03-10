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
    default =  [
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
