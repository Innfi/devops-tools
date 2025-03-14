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

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
    }
  }
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "5.19.0"

  name = "accepter"
  cidr = var.vpc_cidr

  azs = var.azs
  public_subnets = var.public_subnets
  private_subnets = var.private_subnets

  enable_dns_hostnames = true
  enable_flow_log = false

  enable_nat_gateway = true
  single_nat_gateway = true
  map_public_ip_on_launch = true

  tags = {
    "OrderBy" = "Innfi"
  }
}

module "eks" {
  source = "terraform-aws-modules/eks/aws"
  version = "~> 20.31"

  cluster_name = "alpha"
  cluster_version = "1.31"

  cluster_endpoint_public_access = true
  enable_cluster_creator_admin_permissions = true

  vpc_id = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnets

  eks_managed_node_groups = {
    runners = {
      instance_types = ["t3.medium"]

      min_size = 2
      max_size = 3
      desired_size = 2
    }
  }

  node_security_group_additional_rules = {
    ingress_15017 = {
      protocol = "TCP"
      from_port = 15017
      to_port = 15017
      type = "ingress"
      source_cluster_security_group = true
    }
    ingress_15012 = {
      protocol = "TCP"
      from_port = 15012
      to_port = 15012
      type = "ingress"
      source_cluster_security_group = true
    }
  }

  cluster_addons = {
    coredns = {}
    kube-proxy = {}
    vpc-cni = {}
    aws-ebs-csi-driver = {}
  }
}

resource "kubernetes_namespace_v1" "istio_system" {
  metadata {
    name = "istio-system"
  }
}
