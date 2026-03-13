# --- Identification ---

variable "app_name" {
  description = "Name of the application for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name (stage, prod)"
  type        = string
}

# --- Networking ---

variable "vpc_id" {
  description = "The VPC ID discovered via SSM"
  type        = string
}

variable "public_subnets" {
  description = "List of public subnet IDs for the ALB"
  type        = list(string)
}

variable "private_subnets" {
  description = "List of private subnet IDs for ECS tasks"
  type        = list(string)
}

# --- Entry Point & DNS ---

variable "domain_name" {
  description = "The custom domain for CloudFront"
  type        = string
}

variable "acm_cert_arn" {
  description = "ARN of the SSL certificate in us-east-1"
  type        = string
}

variable "waf_acl_arn" {
  description = "ARN of the WAF Web ACL from the security module"
  type        = string
}

# --- ECS Scaling & Sizing ---

variable "desired_count" {
  description = "Number of instances to run"
  type        = number
}

variable "min_count" {
  description = "Minimum instances for autoscaling"
  type        = number
}

variable "max_count" {
  description = "Maximum instances for autoscaling"
  type        = number
}

variable "cpu" {
  description = "Fargate CPU units"
  type        = number
}

variable "memory" {
  description = "Fargate Memory units"
  type        = number
}

# --- Container Configuration ---

variable "container_image" {
  description = "The URI of the Docker image in ECR"
  type        = string
}

variable "container_port" {
  description = "The port the app listens on (e.g., 8080)"
  type        = number
}

# --- External Dependencies (Endpoints) ---

variable "db_endpoint" {
  description = "The RDS primary endpoint address"
  type        = string
}

variable "redis_endpoint" {
  description = "The Redis primary endpoint address"
  type        = string
}

# --- Security Groups ---

variable "alb_sg_id" {
  description = "Security Group ID for the ALB"
  type        = string
}

variable "ecs_sg_id" {
  description = "Security Group ID for the ECS tasks"
  type        = string
}
