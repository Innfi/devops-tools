resource "aws_security_group" "initial" {
  name = "initial"

  vpc_id = var.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "inbound" {
  security_group_id = aws_security_group.initial.id

  ip_protocol = -1
  cidr_ipv4 = var.inbound_cidr
}

resource "aws_vpc_security_group_egress_rule" "outbound" {
  security_group_id = aws_security_group.initial.id

  ip_protocol = -1
  cidr_ipv4 = "0.0.0.0/0"
}