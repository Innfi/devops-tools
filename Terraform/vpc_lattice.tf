// aws_vpclattice_auth_policy

// aws_vpclattice_service_network_vpc_association

// aws_vpclattice_service_network

// aws_vpclattice_service_network_service_association

// aws_vpclattice_target_group

resource "aws_vpclattice_service" "lattice_test" {
  name = "lattice_test"
  auth_type = "AWS_IAM"
  custom_domain_name = "test.com"
}
