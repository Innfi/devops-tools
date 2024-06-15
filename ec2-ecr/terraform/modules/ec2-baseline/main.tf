resource "aws_security_group" "starter_group" {
  name = "starter-group"
  vpc_id = var.vpc_id
}

resource "aws_security_group_rule" "group_rule_ingress" {
  security_group_id = aws_security_group.starter_group.id
  type = "ingress" 
  from_port = var.ingress_port_from
  to_port = var.ingress_port_to
  protocol = "tcp"

  cidr_blocks = var.ingress_cidr_blocks
}

resource "aws_security_group_rule" "group_rule_egress" {
  security_group_id = aws_security_group.starter_group.id
  type = "egress" 
  from_port = 0
  to_port = 0
  protocol = -1

  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_instance" "starter" {
  ami = var.ami_id
  instance_type = "t3a.micro"
  subnet_id = var.subnet_id
  key_name = var.key_name
  vpc_security_group_ids = [aws_security_group.starter_group.id]
}