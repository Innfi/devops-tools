resource "aws_s3_bucket_versioning" "bucket_versioning" {
  provider = aws.central

  bucket = var.s3_id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_replication" "replication_conf" {
  provider = aws.central

  depends_on = [ aws_s3_bucket_versioning.bucket_versioning ]

  role = var.versioning_role_arn
  bucket = var.s3_id

  rule {
    id = "repl_rule"
    status = "Enabled"
    destination {
      bucket = var.s3_dest_arn
      storage_class = "STANDARD"
    }
  }
}