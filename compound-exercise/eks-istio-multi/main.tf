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

module "eks_blueprints_addons" {
  source = "aws-ia/eks-blueprints-addons/aws"
  version = "~> 1.20"

  cluster_name = module.eks.cluster_name
  cluster_endpoint = module.eks.cluster_endpoint
  cluster_version = module.eks.cluster_version
  oidc_provider_arn = module.eks.oidc_provider_arn

  enable_aws_load_balancer_controller = true

  helm_releases = {
    istio-base = {
      chart = "base"
      chart_version = var.istio_chart_version
      repository = var.istio_chart_url
      name = "istio-base"
      namespace = kubernetes_namespace_v1.istio_system.metadata[0].name
    }

    istiod = {
      chart = "istiod"
      chart_version = var.istio_chart_version
      repository = var.istio_chart_url
      name = "istiod"
      namespace = kubernetes_namespace_v1.istio_system.metadata[0].name

      set = [
        {
          name = "meshConfig.accessLogFile"
          value = "/dev/stdout"
        }
      ]
    }

    istio-ingress = {
      chart = "gateway"
      chart_version = var.istio_chart_version
      repository = var.istio_chart_url
      name = "istio-ingress"
      namespace = "istio-ingress"
      create_namespace = true
      
      values = [
        yamlencode({
          labels = {
            istio = "ingressgateway"
          }
          service = {
            annotations = {
              "service.beta.kubernetes.io/aws-load-balancer-type" = "external"
              "service.beta.kubernetes.io/aws-load-balancer-nlb-target-type" = "ip"
              "service.beta.kubernetes.io/aws-load-balancer-scheme" = "internet-facing"
              "service.beta.kubernetes.io/aws-load-balancer-attributes" = "load_balancing.cross_zone.enabled=true"
            }
          }
        })
      ]
    }
  }
}