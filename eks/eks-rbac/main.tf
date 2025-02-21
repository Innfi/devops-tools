locals {
  name = "rbac-eks"
  cluster_version = "1.22"
  region = "ap-northeast-2"

  tags = {
    ClusterTag = "rbac-eks"
  }
}

provider "aws" {
  region = local.region
  shared_credentials_files = [ var.provider_cred_path ]
  profile = var.profile
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = local.name
  cidr = var.vpc_cidr

  azs = ["$(local.region)a", "$(local.region)b"]
  public_subnets = var.public_subnets
  private_subnets = var.private_subnets

  enable_nat_gateway = true
  single_nat_gateway = true
  enable_dns_hostnames = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.name}" = "shared"
    "kubernetes.io.role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.name}" = "shared"
    "kubernetes.io.role/elb" = 1
  }

  tags = local.tags
}

module "iam_readonly" {
  source = "./modules/iam_readonly"
}

module "eks" {
  source = "terraform-aws-modules/eks/aws"

  cluster_name = local.name
  cluster_version = local.cluster_version
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access = true

  vpc_id = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_groups = {
    initial = {
      min_size = 1
      max_size = 2
      desired_size = 1

      instance_types = ["t3.medium"]
      capacity_type = "SPOT"
    }
  }

  # manage_aws_auth_configmap = true
}