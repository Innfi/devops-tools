# Terraform configuration for eks

provider "aws" {
  version = "~> 2.0"
  region = "ap-northeast-2"
}

module "vpc" {
  source = "./modules/vpc"

  azs = var.vpc_azs
  name = var.vpc_name
  cidr = var.vpc_cidr
  subnet_public = var.vpc_public_subnets
  from_port = var.from_port
  to_port = var.to_port
  internal_cidrs = var.internal_cidrs
  cluster_name = var.cluster_name
}

module "eks" {
  source = "./modules/eks"

  vpc_id = module.vpc.vpc_id
  subnet_id_public = module.vpc.subnet_id_public
  subnet_id_private = module.vpc.subnet_id_private
  cluster_name = var.cluster_name
  sg_id_public = module.vpc.sg_id_public
}