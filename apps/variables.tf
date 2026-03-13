# --- IDENTIFICATION ---

variable "app_name" {
  description = "The name of the application (e.g., crm, inventory)"
  type        = string
}

variable "environment" {
  description = "The deployment environment (stage, prod)"
  type        = string
}

# --- REGIONS & NETWORKING ---

variable "primary_region" {
  description = "Primary deployment region (e.g., us-east-1)"
  type        = string
}

variable "secondary_region" {
  description = "DR region for RDS (e.g., us-east-2)"
  type        = string
}

variable "network_ssm_prefix" {
  description = "The SSM path prefix for shared networking (e.g., /infra/stage)"
  type        = string
}

variable "availability_zones" {
  description = "List of the 2 AZs to use for deployment"
  type        = list(string)
}

# --- EDGE & DNS ---

variable "domain_name" {
  description = "The custom domain for the app (e.g., crm-stage.example.com)"
  type        = string
}

variable "acm_certificate_arn" {
  description = "The ARN of the SSL cert in ACM"
  type        = string
}

variable "waf_enabled" {
  description = "Toggle to enable/disable WAF on CloudFront"
  type        = bool
  default     = true
}

# --- COMPUTE (ECS & ALB) ---

variable "desired_count" {
  description = "The baseline number of tasks to run (multiples of 2)"
  type        = number
}

variable "min_count" {
  description = "The minimum number of tasks for auto-scaling"
  type        = number
}

variable "max_count" {
  description = "The maximum number of tasks for auto-scaling"
  type        = number
}

variable "cpu_units" {
  description = "Fargate CPU units (256, 512, 1024)"
  type        = number
}

variable "memory_limit" {
  description = "Fargate memory units (512, 1024, 2048)"
  type        = number
}

variable "container_port" {
  description = "The port the application listens on inside the container"
  type        = number
  default     = 8080
}

variable "container_image" {
  description = "The ECR image URI"
  type        = string
}

# --- SCALING THRESHOLDS ---

variable "cpu_threshold" {
  description = "Average CPU percentage to trigger scale out"
  type        = number
  default     = 70
}

variable "memory_threshold" {
  description = "Average Memory percentage to trigger scale out"
  type        = number
  default     = 80
}

# --- DATA LAYER (RDS) ---

variable "db_name" {
  description = "The name of the database inside RDS"
  type        = string
}

variable "db_engine" {
  description = "The DB engine (postgres or mysql)"
  type        = string
}

variable "db_engine_version" {
  description = "The engine version"
  type        = string
}

variable "db_instance_class" {
  description = "The instance size for the primary region"
  type        = string
}

variable "db_allocated_storage" {
  description = "The initial disk size in GB"
  type        = number
}

variable "db_max_storage" {
  description = "Maximum disk size for storage auto-scaling"
  type        = number
}

variable "multi_az" {
  description = "Whether to create a standby RDS in the second AZ"
  type        = bool
  default     = true
}

variable "enable_dr_replica" {
  description = "Whether to create a cross-region replica in us-east-2"
  type        = bool
  default     = false
}

variable "dr_instance_class" {
  description = "The instance size for the DR region"
  type        = string
}

# --- DATA LAYER (REDIS) ---

variable "redis_node_type" {
  description = "The ElastiCache instance size"
  type        = string
}

variable "redis_engine_version" {
  description = "The Redis version"
  type        = string
}

variable "redis_num_cache_clusters" {
  description = "Number of nodes in the replication group (usually 2)"
  type        = number
}

variable "redis_multi_az_enabled" {
  description = "Enable failover across your 2 AZs"
  type        = bool
  default     = true
}

# --- SENSITIVE DATA ---

variable "db_password" {
  description = "Master password for RDS (Pass via ENV variable)"
  type        = string
  sensitive   = true
}