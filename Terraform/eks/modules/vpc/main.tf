# locals
locals {
  vpc_id = aws_vpc.this.id
}

# vpc
resource "aws_vpc" "this" {
  cidr_block = var.cidr
  instance_tenancy = "default" 
  enable_dns_hostnames = true

  tags = merge(
    {
      "Name" = format("%s", var.name)
    },
    {
      "kubernetes.io/cluster${var.cluster_name}" = "shared"
    },
  )
}

# internet gateway
resource "aws_internet_gateway" "gateway" {
  vpc_id = local.vpc_id

  tags = merge(
    {
      "Name" = format("%s", var.name)
    },
    {
      "kubernetes.io/cluster${var.cluster_name}" = "shared"
    },
  )
}

# subnet
resource "aws_subnet" "public" {
  count = length(var.subnet_public)

  vpc_id = local.vpc_id
  availability_zone = var.azs[count.index]
  cidr_block = var.subnet_public[count.index]

  map_public_ip_on_launch = true

  tags = merge(
    {
      "Name" = format("%s-public-%s", var.name, var.azs[count.index])
    },
    {
      "kubernetes.io/cluster${var.cluster_name}" = "shared"
    },
  )
}

# routing table
resource "aws_route_table" "public" {
  count = length(var.azs) 

  vpc_id = local.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gateway.id
  }

  tags = merge(
    {
      "Name" = format("%s-public-%s", var.name, var.azs[count.index])
    },
    {
      "kubernetes.io/cluster${var.cluster_name}" = "shared"
    },
  )
}

# route table association
resource "aws_route_table_association" "public" {
  count = length(var.azs)

  subnet_id = aws_subnet.public.*.id[count.index]
  route_table_id = aws_route_table.public.*.id[count.index]
}

# security group
resource "aws_security_group" "public" {
  vpc_id = local.vpc_id

  tags = merge(
    {
      "Name" = format("%s-public-%s", var.name, var.azs[count.index])
    },
  )
}

resource "aws_security_group_rule" "ingress_public" {
  security_group_id = aws_security_group.public.id

  type = "ingress"
  from_port = var.from_port
  to_port = var.to_port
  protocol = "tcp"
  cidr_blocks = var.internal_cidrs
}