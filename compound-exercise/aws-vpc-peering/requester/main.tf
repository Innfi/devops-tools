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

module "bastion" {
  source = "./modules/bastion"

  vpc_id = module.vpc.vpc_id
  ingress_cidr_blocks = var.bastion_ingress_cidr_blocks
  ingress_port_from = var.bastion_ingress_port_from
  ingress_port_to = var.bastion_ingress_port_to
  ami = var.bastion_ami
  instance_type = var.bastion_instance_type
  key_name = var.bastion_key_name
  subnet_id = module.vpc.public_subnets[0].id
}
