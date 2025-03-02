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

resource "aws_route_table" "acceptor_to_requester" {
  vpc_id = var.acceptor_vpc_id

  route {
    cidr_block = var.requester_vpc_cidr
    vpc_peering_connection_id = var.peering_connection_id
  }
}

resource "aws_route_table" "requester_to_acceptor" {
  vpc_id = var.requester_vpc_id

  route {
    cidr_block = var.acceptor_vpc_cidr
    vpc_peering_connection_id = var.peering_connection_id
  }
}