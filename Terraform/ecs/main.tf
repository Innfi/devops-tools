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

  name = "test_vpc"
  cidr = "10.0.0.0/16"

  azs = ["ap-northeast-2a", "ap-northeast-2b"]
  public_subnets = ["10.0.1.0/24", "10.0.2.0/24"]

  enable_dns_hostnames = true
}

module "alb" {
  source = "terraform-aws-modules/alb/aws"

  name = "test-alb"

  load_balancer_type = "application"

  vpc_id = module.vpc.vpc_id
  subnets = module.vpc.public_subnets

  security_group_ingress_rules = {
    initial = {
      from_port = 8080
      to_port = 8080
      ip_protocol = "tcp"
      cidr_ipv4 = "0.0.0.0/0"
    }
  }

  security_group_egress_rules = {
    all = {
      ip_protocol = "-1"
      cidr_ipv4 = module.vpc.vpc_cidr_block
    }
  }

  listeners = {
    listener_initial = {
      port = 8080
      protocol = "HTTP"

      forward = {
        target_group_key = "initial_group"
      }
    }
  }

  target_groups = {
    initial_group = {
      backend_protocol = "HTTP"
      backend_port = 3000
      target_type = "ip"

      health_check = {
        enabled = true
        healty_threshoold = 5
        interval = 10
        matcher = "200"
        path = "/health"
        port = "traffic-port"
        protocol = "HTTP"
        timeout = 5
        unhealth_threshold = 2
      }

      create_attachment = false
    }
  }
}

module "ecs_cluster" {
  source = "terraform-aws-ecs/modules/cluster"

  cluster_name = "test_ecs"

  fargate_capacity_providers = {
    FARGATE = {
      default_capacity_provider_strategy = {
        weight = 50
        base = 20
      }
    }
    FARGATE_SPOT = {
      default_capacity_provider_strategy = {
        weight = 50
      }
    }
  }
}

module "ecs_service" {
  source = "terraform-aws-ecs/modules/service"

  name = "test-service"
}

module "ecs_task_definition" {
  source = "terraform-aws-ecs/modules/service"

  name = "test-task"
  cluster_arn = module.ecs_cluster.arn
  subnet_ids = module.vpc.private_subnets

  security_group_rules = {
    egress_all = {
      type = "egress" 
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  runtime_platform = {
    cpu_architecture = "ARM64"
    operating_system_family = "LINUX"
  }

  container_definitions = {
    test_basic_backend = {
      image = "innfi/basic-backend:latest"
    }
  }
}
