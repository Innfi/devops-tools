resource "aws_s3_bucket" "simple_front" {
  bucket = "simple-front"
}

resource "aws_s3_bucket_ownership_controls" "s3_ownership" {
  bucket = aws_s3_bucket.simple_front.id 

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "public_block" {
  bucket = aws_s3_bucket.simple_front.id 

  block_public_acls = false
  block_public_policy = false
  ignore_public_acls = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "simple_front_acl" {
  depends_on = [ 
    aws_s3_bucket_ownership_controls.s3_ownership,
    aws_s3_bucket_public_access_block.public_block,
  ]

  bucket = aws_s3_bucket.simple_front.id

  acl = "public-read"
}

module "cdn" {
  source = "terraform-aws-modules/cloudfront/aws"
  
  aliases = ["cdn.example.com"]

  enabled = true
  http_version = "http2and3"
  is_ipv6_enabled = false
  price_class = "PriceClass_All"
  retain_on_delete = false
  wait_for_deployment = false

  origin = {
    s3_oac = {
      domain_name = "simple-front.s3.ap-northeast-2.amazonaws.com"
      # origin_access_control = aws_s3_bucket_acl.simple_front_acl
    }
  }

  default_cache_behavior = {
    target_origin_id       = "appsync"
    viewer_protocol_policy = "allow-all"
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true
    query_string           = true
  }
}