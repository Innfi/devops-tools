resource "aws_ecr_repository" "ecr_repository" {
  name = var.project_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }
}

resource "aws_s3_bucket" "training_data" {
  bucket = "${var.project_name}_training_data"
}

resource "aws_s3_bucket_acl" "training_data_acl" {
  bucket = aws_s3_bucket.training_data.id
  acl = "private"
}

resource "aws_s3_bucket" "output_data" {
  bucket = "${var.project_name}_output_data"
}

resource "aws_s3_bucket_acl" "training_data_acl" {
  bucket = aws_s3_bucket.output_data.id
  acl = "private"
}