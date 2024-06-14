// aws_vpclattice_auth_policy

resource "aws_vpclattice_service" "lattice_test" {
  name = "lattice_test"
  auth_type = "AWS_IAM"
  custom_domain_name = "test.com"
}

resource "aws_vpclattice_service_network" "lattice_test_network" {
  name = "lattice_test_network"
  auth_type = "AWS_IAM"
}

resource "aws_vpclattice_service_network_service_association" "lattice_test_network_service_association" {
  service_identifier = aws_vpclattice_service.lattice_test.id
  service_network_identifier = aws_vpclattice_service_network.lattice_test_network.id
}

resource "aws_vpclattice_target_group" "target_group_instance" {
  name = "target_group_instance"
  type = "INSTANCE" # "IP", "ALB", "LAMBDA"

  config {
    vpc_identifier = var.vpc_id

    port = 443
    protocol = "HTTPS"
  }
}

resource "aws_vpclattice_service_network_vpc_association" "vpc_association_test" {
  vpc_identifier             = var.vpc_id
  service_network_identifier = aws_vpclattice_service_network.lattice_test_network.id
  security_group_ids         = var.security_group_ids
}