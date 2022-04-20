resource "aws_s3_bucket" "rss_grid" {
  bucket = "rss-grid-${var.name}"
}

resource "aws_s3_bucket_acl" "acl" {
  bucket = aws_s3_bucket.rss_grid.id
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "block_all" {
  bucket = aws_s3_bucket.rss_grid.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

data "aws_iam_policy_document" "s3_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.rss_grid.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.rss_grid.iam_arn]
    }
  }

  statement {
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.rss_grid.arn]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.rss_grid.iam_arn]
    }
  }
}

resource "aws_s3_bucket_policy" "cloudfront_access" {
  bucket = aws_s3_bucket.rss_grid.id
  policy = data.aws_iam_policy_document.s3_policy.json
}
