variable "env" {
  type        = string
  description = "The deployment environment (e.g., dev, stage, prod)."
}

variable "app_name" {
  type        = string
  description = "The name of the service (e.g., ciam, web, crm, ecommerce)."
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC where the data resources reside."
}

# Networking & Security
variable "db_subnet_ids" {
  type        = list(string)
  description = "The list of private subnet IDs for the database and cache layer."
}

variable "dr_db_subnet_ids" {
  type        = list(string)
  description = "The list of private subnet IDs for the database and cache layer for dr rds."
}

variable "db_security_group_id" {
  type        = string
  description = "The Security Group ID allowing access from ECS and the DevOps VPN."
}

variable "dr_db_security_group_id" {
  type        = string
  description = "The Security Group ID allowing access from ECS and the DevOps VPN for DR"
}

# Engine Configurations
variable "db_engine" {
  type    = string
  default = "postgres"
}

variable "db_instance_class" {
  type    = string
  default = "db.t3.medium"
}

variable "redis_node_type" {
  type    = string
  default = "cache.t3.micro"
}