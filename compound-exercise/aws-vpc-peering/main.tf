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

  tags = {
    "OrderBy" = "Innfi"
  }
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

  tags = {
    "OrderBy" = "Innfi"
  }
}

# should be initialized after both vpcs are created
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

  tags = {
    "OrderBy" = "Innfi"
  }
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
  source = "./modules/rds"
  db_subnets = module.vpc_accepter.private_subnets

  requester_vpc_id = module.vpc_requester.vpc_id
}
