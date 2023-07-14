resource "aws_vpc_peering_connection" "test_peering" {
  peer_owner_id = var.owner_id
  peer_vpc_id = var.peer_vpc_id
  vpc_id = var.vpc_id
  peer_region = "ap-northeast-2"
  auto_accept = true

  tags = {
    Name = "test peering"
  }
}