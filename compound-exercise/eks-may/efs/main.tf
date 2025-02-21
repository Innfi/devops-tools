resource "aws_efs_file_system" "efs-may" {
  creation_token = "efs-may"

  availability_zone_name = var.az_name

  lifecycle_policy {
    transition_to_ia = "AFTER_7_DAYS"
  }
}