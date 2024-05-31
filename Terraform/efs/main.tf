resource "aws_security_group" "efs-sg" {
  name = "efs-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port = 2049
    to_port = 2049
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_efs_file_system" "efs" {
  availability_zone_name = var.az
  encrypted = false 
  performance_mode = "generalPurpose"
  throughput_mode = "bursting"

  lifecycle_policy {
    transition_to_ia = "AFTER_7_DAYS"
  }
}

resource "aws_efs_mount_target" "mount-target" {
  file_system_id = aws_efs_file_system.efs.id
  subnet_id = var.subnet_id 
  security_groups = [aws_security_group.efs-sg.id]
}

# need mount -t fns4 ... command for target ec2 instance