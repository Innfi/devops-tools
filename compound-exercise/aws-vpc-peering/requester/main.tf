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
  source = "terraform-aws-modules/vpc/aws"
  version = "5.19.0"

  name = "requester"
  cidr = var.vpc_cidr

  azs = var.azs
  public_subnets = var.public_subnets
  private_subnets = var.private_subnets

  enable_dns_hostnames = true
  enable_flow_log = false
}

module "connector" {
  source = "./modules/connector"

  vpc_id = module.vpc.vpc_id
  acceptor_vpc_id = var.acceptor_vpc_id
  target_cidr_blocks = var.target_cidr_blocks
}
