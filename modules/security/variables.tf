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
  description = "The ID of the VPC where these Security Groups will be created."
}


variable "dr_vpc_id" {
  type        = string
  description = "The ID of the VPC where these Security Groups will be created for Disaster Recovery."
}

variable "product_team" {
  type        = string
  description = "The team responsible for the resource."
  default     = "Customer Solutions"
}

variable "vpn_cidr" {
  type        = string
  description = "The CIDR block of the DevOps VPN to allow internal management access."
}

variable "primary_vpc_cidr" {
  type        = string
  description = "The CIDR block of the primary vpc in ap-northeast-1"
}