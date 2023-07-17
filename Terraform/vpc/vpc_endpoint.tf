resource "aws_vpc_endpoint" "test_endpoint" {
  vpc_id = var.vpc_id
  service_name = "test_endpoint" 
  vpc_endpoint_type = "Interface"

  secruity_group_ids = [
    var.target_sg_id,
  ]

  subnet_ids = var.subnet_ids
  private_dns_enabled = true
}