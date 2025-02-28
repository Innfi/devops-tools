resource "aws_security_group" "bastion" {
  name = "starter-group"
  vpc_id = var.vpc_id
}

resource "aws_security_group_rule" "group_rule_ingress" {
  security_group_id = aws_security_group.bastion.id
  type = "ingress" 
  from_port = var.ingress_port_from
  to_port = var.ingress_port_to
  protocol = "tcp"

  cidr_blocks = var.ingress_cidr_blocks
}

resource "aws_instance" "bastion"{
  ami = var.ami
  instance_type = var.instance_type

  key_name = var.key_name

  subnet_id = var.subnet_id
  vpc_security_group_ids = [aws_security_group.bastion.id]
  associate_public_ip_address = true
}