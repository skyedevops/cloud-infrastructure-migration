locals {
  static_assets_bucket_name = var.static_assets_bucket_name != "" ? var.static_assets_bucket_name : "${var.project_name}-static-${data.aws_caller_identity.current.account_id}"
}

resource "aws_s3_bucket" "static_assets" {
  count  = var.enable_static_assets ? 1 : 0
  bucket = local.static_assets_bucket_name

  tags = merge(var.tags, {
    Name = "${var.project_name}-static-assets"
  })

  lifecycle {
    ignore_changes = [bucket]
  }
}

resource "aws_s3_bucket_public_access_block" "static_assets" {
  count  = var.enable_static_assets ? 1 : 0
  bucket = aws_s3_bucket.static_assets[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "static_assets" {
  count  = var.enable_static_assets ? 1 : 0
  bucket = aws_s3_bucket.static_assets[0].id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "static_assets" {
  count  = var.enable_static_assets ? 1 : 0
  bucket = aws_s3_bucket.static_assets[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "static_assets" {
  count  = var.enable_static_assets ? 1 : 0
  bucket = aws_s3_bucket.static_assets[0].id

  rule {
    id     = "transition-to-ia"
    status = "Enabled"

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 90
      storage_class = "GLACIER"
    }

    noncurrent_version_expiration {
      noncurrent_days = 30
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

# Origin Access Control for CloudFront -> S3
resource "aws_cloudfront_origin_access_control" "static_assets" {
  count                             = var.enable_static_assets ? 1 : 0
  name                              = "${var.project_name}-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# Bucket policy allowing CloudFront OAC reads
resource "aws_s3_bucket_policy" "static_assets" {
  count  = var.enable_static_assets ? 1 : 0
  bucket = aws_s3_bucket.static_assets[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.static_assets[0].arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.static_assets[0].arn
          }
        }
      }
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.static_assets]
}

resource "aws_cloudfront_distribution" "static_assets" {
  count               = var.enable_static_assets ? 1 : 0
  enabled             = true
  comment             = "${var.project_name} static assets"
  default_root_object = "index.html"
  price_class         = "PriceClass_100"
  http_version        = "http2and3"
  is_ipv6_enabled     = true

  origin {
    domain_name              = aws_s3_bucket.static_assets[0].bucket_regional_domain_name
    origin_id                = "s3-${var.project_name}-static"
    origin_access_control_id = aws_cloudfront_origin_access_control.static_assets[0].id
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "s3-${var.project_name}-static"
    viewer_protocol_policy = "redirect-to-https"
    compress               = true

    cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6" # CachingOptimized
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = var.tags
}
