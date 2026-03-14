variable "domain_name" {
  type        = string
  description = "The primary domain name (e.g., example.com)"
}

variable "public_zone_id" {
  type        = string
  description = "The Route 53 Public Zone ID where validation records will be created"
}

variable "env" {
  type        = string
  description = "Environment name (dev/prod)"
}

variable "app_name" {
  type        = string
  description = "Application name"
}