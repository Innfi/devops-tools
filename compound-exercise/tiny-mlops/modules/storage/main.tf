resource "aws_efs_file_system" "storage" {
  creation_token = "storage"  

  lifecycle_policy {
    transition_to_ia = "AFTER_365_DAYS"
  }
}