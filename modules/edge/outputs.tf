output "internal_zone_id" {
  description = "The ID of the Private Hosted Zone for internal service discovery"
  value       = aws_route53_zone.internal.zone_id
}

output "internal_domain_name" {
  description = "The base domain for internal records (e.g., app.internal)"
  value       = aws_route53_zone.internal.name
}

output "cloudfront_domain_name" {
  description = "The domain name of the CloudFront distribution"
  value       = aws_cloudfront_distribution.main.domain_name
}

output "cloudfront_hosted_zone_id" {
  description = "The Route 53 Zone ID for the CloudFront distribution (used for Alias records)"
  value       = aws_cloudfront_distribution.main.hosted_zone_id
}

output "cloudfront_arn" {
  description = "The ARN of the CloudFront distribution"
  value       = aws_cloudfront_distribution.main.arn
}