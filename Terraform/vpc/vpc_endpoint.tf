# interface endpoint
resource "aws_vpc_endpoint" "test_interface_endpoint" {
  vpc_id = var.vpc_id
  service_name = "test_endpoint" 
  vpc_endpoint_type = "Interface"

  secruity_group_ids = [
    var.target_sg_id,
  ]

  subnet_ids = var.subnet_ids
  private_dns_enabled = true
}

# gateway endpoint
resource "aws_vpc_endpoint_service" "endpoint_service" {
  acceptance_required = false
  allowed_principals = [var.current_caller_arn]
  gateway_load_balancer_arns = [var.loadbalancer_arn]
}

resource "aws_vpc_endpoint" "test_gateway_endpoint" {
  service_name = aws_vpc_endpoint_service.endpoint_service.service_name
  vpc_endpoint_type = aws_vpc_endpoint_service.endpoint_service.service_type
  vpc_id = var.vpc_id
  subnet_ids = [var.test_subnet_id]
}