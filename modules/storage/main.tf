locals {
  common_tags = {
    Environment = var.env
    Application = var.app_name
    ManagedBy   = "Terraform"
  }
}

# 1. S3 Bucket for Static UI
resource "aws_s3_bucket" "static_ui" {
  bucket = "${var.app_name}-${var.env}-ui-assets"

  tags = local.common_tags
}

# 2. Block Public Access
resource "aws_s3_bucket_public_access_block" "block_public" {
  bucket = aws_s3_bucket.static_ui.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# 3. Bucket Policy to allow CloudFront OAC access
resource "aws_s3_bucket_policy" "allow_cloudfront" {
  bucket = aws_s3_bucket.static_ui.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "s3:GetObject"
        Effect   = "Allow"
        Resource = "${aws_s3_bucket.static_ui.arn}/*"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Condition = {
          StringEquals = {
            # This ensures ONLY your specific CloudFront distribution can see the files
            "AWS:SourceArn" = var.cloudfront_arn
          }
        }
      }
    ]
  })
}