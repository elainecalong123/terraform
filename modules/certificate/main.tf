# 1. Request the Certificate
resource "aws_acm_certificate" "this" {
  domain_name       = var.domain_name
  validation_method = "DNS"

  # Adds support for subdomains (e.g., api.example.com, ciam.example.com)
  subject_alternative_names = ["*.${var.domain_name}"]

  tags = {
    Name        = "${var.app_name}-${var.env}-cert"
    Environment = var.env
  }

  lifecycle {
    create_before_destroy = true
  }
}

# 2. Create DNS Validation Records in Route53
# This logic loops through the domain validation options provided by ACM
resource "aws_route53_record" "validation" {
  for_each = {
    for dvo in aws_acm_certificate.this.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = var.public_zone_id
}

# 3. The Validation Bridge
# Terraform will "hang" or wait here until the certificate status is 'ISSUED'
resource "aws_acm_certificate_validation" "this" {
  certificate_arn         = aws_acm_certificate.this.arn
  validation_record_fqdns = [for record in aws_route53_record.validation : record.fqdn]
}