resource "aws_s3_bucket" "static_web" {
  bucket = "static_web"
}

resource "aws_s3_bucket_ownership_controls" "ownership" {
  bucket = aws_s3_bucket.static_web.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "static_web_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.ownership]

  bucket = aws_s3_bucket.static_web.id
  acl    = "public-read"
}

resource "aws_s3_bucket_website_configuration" "static_web_conf" {
  bucket = aws_s3_bucket.static_web.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html" // for react apps
  }

  routing_rule {
    condition {
      key_prefix_equals = "src/"
    }

    redirect {
      replace_key_prefix_with = "dest/"
    }
  }
}