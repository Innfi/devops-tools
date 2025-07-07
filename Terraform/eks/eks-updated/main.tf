terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
  shared_credentials_files = var.shared_credentials_files
  profile = var.profile
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "5.19.0"

  name = "vpc"
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

#eks requires security groups, for the cluster and the node group

module "eks" {
  source = "terraform-aws-modules/eks/aws"
  version = "~>20.31"

  cluster_name = var.cluster_name
  cluster_version = var.cluster_version
  vpc_id = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  enable_cluster_creator_admin_permissions = true 

  cluster_endpoint_public_access = true 
  cluster_endpoint_public_access_cidrs = var.cluster_endpoint_public_access_cidrs

  cluster_security_group_id = var.cluster_security_group_id

  eks_managed_node_groups = {
    private_nodes = {
      instance_type = var.node_group_instance_types
      min_size = var.node_group_min_size
      max_size = var.node_group_max_size
      desired_size = var.node_group_desired_size

      subnet_ids = module.vpc.private_subnets
      vpc_security_group_ids = var.private_security_group_ids

      label = {
        node_label = "private_nodes"
      }
    }

    public_nodes = {
      instance_type = var.node_group_instance_types
      min_size = var.node_group_min_size
      max_size = var.node_group_max_size
      desired_size = var.node_group_desired_size

      subnet_ids = module.vpc.public_subnets
      vpc_security_group_ids = var.public_security_group_ids

      label = {
        node_label = "public_nodes"
      }
    }

    # deployment affinity example
    # spec:
    #   template:
    #     spec:
    #       affinity:
    #         nodeAffinity:
    #           requiredDuringSchedulingIgnoredDuringExecution:
    #             nodeSelectorTerms:
    #               - matchExpressions:
    #                   - key: node_label
    #                     operator: In
    #                     values:
    #                       - private_nodes
  }

  # or resource "aws_eks_access_policy_association" after cluster creation
  access_entries = {
    tester = {
      principal_arn = var.access_entry_arn
      policy_associations = {
        test_connection = {
          policy_arn = var.tester_policy_arn
        }
      }
    }

    example = {
      principal_arn = var.example_arn

      policy_associations = {
        example = {
          policy_arn = var.example_policy_arn
          access_scope = {
            namespaces = ["default"]
            type       = "namespace"
          }
        }
      }
    }
  }

  cluster_addons = {
    coredns = {}
    kube_proxy = {}
    vpc-cni = {}
    aws-ebs-csi-driver = {}
  }
}