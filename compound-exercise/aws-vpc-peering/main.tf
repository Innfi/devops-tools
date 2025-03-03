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

module "vpc_accepter" {
  source = "terraform-aws-modules/vpc/aws"
  version = "5.19.0"

  name = "accepter"
  cidr = var.accepter_vpc_cidr

  azs = var.azs
  public_subnets = var.accepter_public_subnets
  private_subnets = var.accepter_private_subnets

  enable_dns_hostnames = true
  enable_flow_log = false

  enable_nat_gateway = true
  single_nat_gateway = true
  map_public_ip_on_launch = true
}

module "vpc_requester" {
  source = "terraform-aws-modules/vpc/aws"
  version = "5.19.0"

  name = "requester"
  cidr = var.requester_vpc_cidr

  azs = var.azs
  public_subnets = var.requester_public_subnets
  private_subnets = var.requester_private_subnets

  enable_nat_gateway = true
  single_nat_gateway = true
  map_public_ip_on_launch = true

  enable_dns_hostnames = true
  enable_flow_log = false
}

# should be inialized after both vpcs are created
module "vpc_peering" {
  source = "cloudposse/vpc-peering/aws"

  auto_accept = true
  requestor_vpc_id = module.vpc_requester.vpc_id
  requestor_allow_remote_vpc_dns_resolution = true
  acceptor_vpc_id = module.vpc_accepter.vpc_id
  acceptor_allow_remote_vpc_dns_resolution = true

  depends_on = [
    module.vpc_requester,
    module.vpc_accepter
  ]
}

module "bastion" {
  source = "./modules/bastion"

  vpc_id = module.vpc_requester.vpc_id
  ingress_cidr_blocks = var.bastion_ingress_cidr_blocks
  ingress_port_from = var.bastion_ingress_port_from
  ingress_port_to = var.bastion_ingress_port_to
  key_name = var.bastion_key_name
  subnet_id = module.vpc_requester.public_subnets[0]
}

module "rds" {
  source  = "terraform-aws-modules/rds/aws"
  
  identifier = "accepter"
  
  engine = "mysql"
  engine_version = "8.0.40"
  instance_class = "db.t3.micro"

  create_db_subnet_group = false
  subnet_ids = module.vpc_accepter.private_subnets

  manage_master_user_password = false
  username = var.db_master_username
  password = var.db_password
}
