locals {
  rds_name = "innfis_db"
  sg_ids = [ "security_group_ids" ]
}

resource "aws_db_instance" "rds_bluegreen" {
  allocated_storage = 50
  max_allocated_storage = 100
  db_name = local.rds_name
  engine = "mysql"
  engine_version = "5.8"
  instance_class = "db.t3.medium"
  parameter_group_name = "default.mysql5.8" 
  vpc_security_group_ids = local.sg_ids
  blue_green_update {
    enabled = true
  }

  performance_insights_enabled = true
}