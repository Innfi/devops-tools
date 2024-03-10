resource "aws_s3_bucket" "state-backup-s3" {
  bucket = "state-backup-s3"
}

resource "aws_s3_bucket_acl" "backup-acl" {
  bucket = aws_s3_bucket.state-backup-s3.id
  acl = "private"
}

resource "aws_s3_bucket_versioning" "state-backup-versioning" {
  bucket = aws_s3_bucket.state-backup-s3.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_dynamo_table" "state-lock" {
  name = "state-lock"
  hash_key = "TestKey"
  billing_mode     = "PAY_PER_REQUEST"

  attribute {
    name = "TestKey"
    type = "S"
  }
}