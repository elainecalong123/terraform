output "certificate_arn" {
  description = "The validated ARN of the certificate"
  value       = aws_acm_certificate_validation.this.certificate_arn
}