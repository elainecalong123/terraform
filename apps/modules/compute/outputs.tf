# modules/compute/outputs.tf
output "cloudfront_domain_name" {
  value = aws_cloudfront_distribution.main.domain_name
}

output "alb_dns_name" {
  value = aws_lb.main.dns_name
}