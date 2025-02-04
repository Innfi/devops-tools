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
  shared_credentials_files = var.credential_files
  profile = var.profile
}

module "storage" {
  source = "./modules/storage"
}

data "aws_availability_zones" "available" {}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.vpc_name
  cidr = var.vpc_cidr

  azs                 = var.azs
  private_subnets     = [for k, v in var.azs : cidrsubnet(var.vpc_cidr, 8, k)]
  public_subnets      = [for k, v in var.azs : cidrsubnet(var.vpc_cidr, 8, k + 4)]

  enable_dns_hostnames = true
  enable_dns_support = true

  enable_nat_gateway = true
  enable_dhcp_options = true
}