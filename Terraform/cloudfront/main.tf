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

resource "aws_cloudfront_origin_access_control" "oac" {
  name = "oac_s3"
  origin_access_control_origin_type = "s3"
  signing_behavior = "always"
  signing_protocol = "sigv4"
}

resource "aws_cloudfront_cache_policy" "test-policy" {
  name = "test-policy"
  default_ttl = 50
  max_ttl = 100
  min_ttl = 1

  parameters_in_cache_key_and_forwarded_to_origin {
    cookies_config {
      cookie_behavior = "all"
    }

    headers_config {
      header_behavior = "whitelist"
      headers {
        items = [""]
      }
    }

    query_strings_config {
      query_string_behavior = "none"
    }
  }
}

resource "aws_cloudfront_distribution" "cdn_from_s3" {
  origin {
    domain_name = var.s3_domain_name
    origin_id = var.origin_id
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
  }

  enabled = true
  default_root_object = "root_page.html"

  default_cache_behavior {
    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods = ["GET", "HEAD"]

    target_origin_id = var.origin_id

    viewer_protocol_policy = "allow-all"
    cache_policy_id = aws_cloudfront_cache_policy.test-policy.id
  }

  viewer_certificate {
    acm_certificate_arn = var.certificate_arn
  }

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations = ["KR"]
    }
  }

  aliases = [ var.cdn_domain ]
}

resource "aws_route53_record" "domain_cdn" {
  zone_id = var.route53_zone_id
  name = var.cdn_domain
  type = "A"
  ttl = 300

  records = aws_cloudfront_distribution.cdn_from_s3.doamin_name
}
