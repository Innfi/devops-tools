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

  name = "august"
  cidr = "10.10.0.0/16"

  azs = ["ap-northeast-2a", "ap-northeast-2b"]
  public_subnets = ["10.10.0.0/20", "10.10.96.0/20"]

  enable_dns_hostnames = true
}