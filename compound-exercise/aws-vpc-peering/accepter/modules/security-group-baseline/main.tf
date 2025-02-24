resource "aws_security_group" "sg_baseline" {
  name = "sg_baseline"

  vpc_id = var.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "ingress_bastion" {
  security_group_id = aws_security_group.sg_baseline.id
  cidr_ipv4 = var.cidr_ipv4
  from_port = var.from_port
  to_port = var.to_port
  ip_protocol = var.protocol
}
