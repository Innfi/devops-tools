# Terraform configuration for eks

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 3.55"
    }
  }
}

provider "aws" {
  region = "ap-northeast-2"
  shared_credentials_file = var.provider_cred_path
  profile = var.profile
}

module "vpc" {
  source = "./modules/vpc"

  azs = var.vpc_azs
  name = var.vpc_name
  cidr = var.vpc_cidr
  subnet_public = var.vpc_public_subnets
  subnet_private = var.vpc_private_subnets
  from_port = var.from_port
  to_port = var.to_port
  internal_cidrs = var.internal_cidrs
  cluster_name = var.cluster_name
}

module "eks" {
  source = "./modules/eks"

  vpc_id = module.vpc.vpc_id
  name = var.vpc_name
  subnet_id_public = module.vpc.subnet_id_public
  #subnet_id_private = module.vpc.subnet_id_private
  cluster_name = var.cluster_name
  sg_id_public = module.vpc.sg_id_public
  #sg_id_private = module.vpc.sg_id_private
}