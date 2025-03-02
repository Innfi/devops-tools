resource "aws_vpc_peering_connection" "peering" {
  vpc_id = var.vpc_id
  peer_vpc_id = var.acceptor_vpc_id
}

resource "aws_security_group" "requester" {
  name = "requester"

  vpc_id = var.vpc_id

  ingress {
    from_port = 0
    to_port = 0
    protocol = "tcp"
    cidr_blocks = var.target_cidr_blocks
  }
}
