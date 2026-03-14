variable "env" {
  type        = string
  description = "The deployment environment (e.g., dev, stage, prod)."
}

variable "app_name" {
  type        = string
  description = "The name of the service (e.g., ciam, web, crm, ecommerce)."
}

variable "product_team" {
  type        = string
  description = "The team responsible for the resource (e.g., Customer Solutions)."
  default     = "Customer Solutions"
}

variable "primary_db_arn" {
  type        = string
  description = "db arn of the rds in primary region"
}

variable "dr_db_arn" {
  type        = string
  description = "db arn of the rds in dr region"
}

variable "redis_cluster_arn" {
  type        = string
  description = "The ARN of the Redis/ElastiCache cluster this app is allowed to access."
}