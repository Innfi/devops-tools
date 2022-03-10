# Terraform configuration for eks

provider "aws" {
  version = "~> 2.0"
  region = "ap-northeast-2"
}

module "test-eks" {
  source = "./test-eks"

  azs = var.vpc_azs
  name = var.vpc_name
  cidr = var.vpc_cidr
  subnet_public = var.vpc_public_subnets
  subnet_private = var.vpc_private_subnets
}