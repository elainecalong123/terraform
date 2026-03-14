
output "bucket_id" {
  description = "bucket id for s3 hosting static ui"
  value = aws_s3_bucket.static_ui.id
}

output "s3_bucket_arn" {
  description = "The ARN of the bucket (needed for IAM/Bucket Policies)"
  value       = aws_s3_bucket.static_ui.arn
}

output "s3_bucket_regional_domain_name" {
  description = "The regional DNS name of the bucket (needed for CloudFront)"
  value       = aws_s3_bucket.static_ui.bucket_regional_domain_name
}