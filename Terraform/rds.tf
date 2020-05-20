resource "aws_db_instance" "test_rds" {
    allocated_storage = 20 
    storage_type = "gp2" 
    engine = "mysql"
    engine_version = "5.7" 
    instance_class = "db.t2.micro" 
    name = "test_rds" 
    username = "innfi" 
    password = "innfisrds"
    parameter_group_name = "default.mysql5.7" 
    vpc_security_group_ids = [aws_security_group.test_sg.id] 
}