resource "aws_security_group" "database" {
  name = "database security group"
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = var.db_sg_ingress_cidr
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_subnet_group" "rds" {
  name = "subnet_group"
  subnet_ids = var.db_subnets
}

resource "aws_db_instance" "rds" {
  identifier_prefix = "rds"
  engine = "mysql"
  engine_version = "mysql8.0"
  allocated_storage = 10
  instance_class = "db.t3g.micro"
  db_name = "innfisdb"
  username = var.db_username
  password = var.db_password
  db_subnet_group_name = aws_db_subnet_group.rds.name
  vpc_security_group_ids = ["${aws_security_group.database.id}"]
  skip_final_snapshot = false
}

resource "aws_vpc_security_group_vpc_association" "association" {
  security_group_id = aws_security_group.database.id
  vpc_id = var.requester_vpc_id
}