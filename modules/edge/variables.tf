# --- General Project Variables ---
variable "env" {
  description = "Environment name (e.g., dev, prod)"
  type        = string
}

variable "app_name" {
  description = "Application name used for resource naming"
  type        = string
}

# --- VPC & Networking ---
variable "vpc_id" {
  description = "The ID of the Primary VPC (Singapore) for the Private Hosted Zone"
  type        = string
}

variable "public_zone_id" {
  description = "The Route 53 Public Hosted Zone ID for your domain"
  type        = string
}

variable "domain_name" {
  description = "The primary domain name (e.g., app.yourdomain.com)"
  type        = string
}

# --- Origin Endpoints ---
variable "alb_dns_name" {
  description = "The DNS name of the Singapore Application Load Balancer"
  type        = string
}

variable "s3_bucket_regional_domain_name" {
  description = "The regional DNS name of the S3 bucket from the storage module"
  type        = string
}

variable "rds_primary_endpoint" {
  description = "The address/endpoint of the primary RDS instance"
  type        = string
}

variable "redis_primary_endpoint" {
  description = "The primary endpoint address for the Redis cluster"
  type        = string
}

# --- Security & Certificates ---
variable "acm_certificate_arn" {
  description = "The ARN of the ACM certificate. MUST be in the us-east-1 region for CloudFront"
  type        = string
}