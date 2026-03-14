variable "env" {
  type        = string
  description = "The deployment environment (e.g., dev, stage, prod)."
}

variable "app_name" {
  type        = string
  description = "The name of the service (e.g., shared-rds)."
}

# --- Networking ---
variable "vpc_id" {
  type        = string
  description = "The ID of the Primary VPC (Singapore)."
}

variable "dr_vpc_id" {
  type        = string
  description = "The ID of the DR VPC (Sydney) for the replica's Security Group."
}

variable "primary_vpc_cidr" {
  type        = string
  description = "The CIDR of the primary VPC to allow cross-region replication/access."
}

variable "db_username" {
  type        = string
  description = "The master username for the database"
  default     = "dbadmin"
}

variable "db_allocated_storage" {
  type    = number
  default = 20
}


variable "vpn_cidr" {
  type        = string
  description = "The CIDR block of the DevOps VPN for administrative access."
}

variable "db_subnet_ids" {
  type        = list(string)
  description = "The list of private subnet IDs for the primary database layer."
}

variable "dr_db_subnet_ids" {
  type        = list(string)
  description = "The list of private subnet IDs for the DR database layer."
}

# --- Engine Configurations ---
variable "db_engine" {
  type    = string
  default = "postgres"
}

variable "db_instance_class" {
  type    = string
  default = "db.t3.medium"
}

variable "db_password" {
  type        = string
  description = "The master password for the database."
  sensitive   = true
}

variable "redis_node_type" {
  type    = string
  default = "cache.t3.micro"
}

variable "internal_domain_name" {
  type        = string
  description = "The base internal domain for Route 53"
  default     = "cambridgelaine.internal"
}

variable "db_backup_retention_period" {
  type        = number
  description = "The days to retain backups. Must be 1-35 for replicas."
  default     = 1
}

variable "dr_db_backup_retention_period" {
  type        = number
  description = "The days to retain backups. Must be 1-35 for replicas."
  default     = 1
}

variable "db_backup_window" {
  type        = string
  description = "The daily time range (in UTC) during which automated backups are created."
  default     = "03:00-04:00"
}

variable "rds_custom_parameters" {
  type = list(object({
    name  = string
    value = string
  }))
  default = [
    {
      name  = "rds.force_ssl"
      value = "1"
    },
    {
      name  = "log_min_duration_statement"
      value = "1000"
    }
  ]
  description = "Custom PostgreSQL parameters for security and observability."
}