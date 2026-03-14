variable "env" { type = string }
variable "app_name" { type = string }
variable "vpc_id" { type = string }

# Networking
variable "public_subnet_ids" { type = list(string) }
variable "private_subnet_ids" { type = list(string) }

# Security Groups
variable "alb_sg_id" { type = string }
variable "ecs_sg_id" { type = string }

# IAM & Cluster
variable "execution_role_arn" { type = string }
variable "task_role_arn" { type = string }

# Endpoints
variable "db_host" { type = string }
variable "redis_host" { type = string }
variable "acm_certificate_arn" { type = string }

# Container
variable "container_image" { type = string }
variable "container_port" { default = 8080 }
variable "cpu" { default = 256 }
variable "memory" { default = 512 }