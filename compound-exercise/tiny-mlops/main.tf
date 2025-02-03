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
  shared_credentials_files = var.credential_files
  profile = var.profile
}

module "storage" {
  source = "./modules/storage"
}
