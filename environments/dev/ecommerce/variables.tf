variable "env" {
  type        = string
  description = "Environment name (dev/prod)"
}

variable "region" {
  type        = string
  description = "Primary AWS region"
}

variable "app_name" {
  type        = string
  description = "The name of the application (e.g., ecommerce, crm)"
}

variable "domain_name" {
  type        = string
  description = "The full domain name for the application"
}

variable "vpn_cidr" {
  type        = string
  description = "vpn cidr"
}

variable "container_image" {
  type        = string
  description = "container image testing"
}

