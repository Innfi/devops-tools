terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-2"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.8.1"

  name = "june"
  cidr = "10.0.0.0/16"

  azs = ["ap-northeast-2a", "ap-northeast-2b"]
  public_subnets = ["10.0.1.0/24", "10.0.2.0/24"]

  enable_dns_hostnames = true
}

module "ecr_baseline" {
  source = "./modules/ecr"
}

module "ecr_user" {
  source = "./modules/ecr-user"

  ecr_arn = module.ecr_baseline.arn
}

# module "ec2_baseline" {
#   source = "./modules/ec2-baseline"
# 
#   vpc_id = module.vpc.vpc_id
#   subnet_id = module.vpc.public_subnets[0]
# }