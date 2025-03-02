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

  name = "peering_test"
  cidr = var.vpc_cidr

  azs = var.azs
  public_subnets = var.public_subnets
  private_subnets = var.private_subnets

  enable_dns_hostnames = true
  enable_flow_log = false

  enable_nat_gateway = true
  single_nat_gateway = true
  map_public_ip_on_launch = true
}

module "security-group-baseline" {
  source = "./modules/security-group-baseline"

  vpc_id = module.vpc.vpc_id
}

# module "rds" {
#   source = "terraform-aws-modules/rds/aws"
# 
#   identifier = "test-rds"
#   engine = "mysql"
#   engine_version = "8.0"
#   family = "mysql8.0"
#   major_engine_version = "8.0"
#   instance_class = "db.t2.micro"
#   allocated_storage = 20
# 
#   db_name = var.db_name
#   username = var.db_username
#   port = var.db_port
# 
#   db_subnet_group_name = module.vpc.private_subnet
#   vpc_security_group_ids = [module.security-group-baseline.security_group_output[0].id]
# 
#   create_db_subnet_group = false
#   subnet_ids = module.vpc.private_subnets
# }