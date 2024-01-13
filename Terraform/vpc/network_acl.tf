resource "aws_network_acl" "main" {
  vpc_id = var.vpc_id

  ingress {
    rule_no = 100
    protocol = "tcp"
    action = "deny"
    cidr_block = var.ingress_cidr
    from_port = -1
    to_port = -1
  }

  egress = {
    protocol = -1
    rule_no = 100
    action = "allow"
    cidr_block = "0.0.0.0/0"
    from_port = -1
    to_port = -1
  }
}