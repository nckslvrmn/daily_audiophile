resource "aws_cloudfront_distribution" "rss_grid" {
  origin {
    domain_name = aws_s3_bucket.rss_grid.bucket_domain_name
    origin_id   = aws_s3_bucket.rss_grid.id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.rss_grid.cloudfront_access_identity_path
    }
  }

  enabled         = true
  is_ipv6_enabled = false

  aliases             = ["${var.name}.${var.dns_domain}"]
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_s3_bucket.rss_grid.id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 300
    max_ttl                = 1200
  }

  ordered_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_s3_bucket.rss_grid.id
    path_pattern     = "/*"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "https-only"
    min_ttl                = 0
    default_ttl            = 900
    max_ttl                = 900
  }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = var.acm_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
}

resource "aws_cloudfront_origin_access_identity" "rss_grid" {
  comment = "CFOAI for accessing s3 origin assets"
}
