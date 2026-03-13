# --- Entry Points ---
output "application_url" {
  description = "The URL of your application via CloudFront"
  value       = "https://${var.domain_name}"
}

output "cloudfront_domain_name" {
  description = "The raw CloudFront distribution domain"
  value       = module.compute.cloudfront_domain_name
}

output "load_balancer_dns" {
  description = "The DNS of the Application Load Balancer (Internal/Debugging)"
  value       = module.compute.alb_dns_name
}

# --- Data Layer Endpoints ---
output "rds_primary_endpoint" {
  description = "Primary RDS Endpoint in us-east-1"
  value       = module.data.rds_endpoint
}

output "rds_dr_replica_endpoint" {
  description = "Disaster Recovery RDS Endpoint in us-east-2"
  value       = module.data.rds_dr_endpoint
}

output "redis_primary_endpoint" {
  description = "Redis Primary Endpoint"
  value       = module.data.redis_endpoint
}

# --- Deployment Summary ---
output "deployment_info" {
  description = "Summary of what was deployed"
  value       = "Successfully deployed ${var.app_name} to the ${var.environment} environment across 2 Availability Zones."
}