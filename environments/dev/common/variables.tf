# --- Global / Project Variables ---
variable "env" {
  description = "The environment name (e.g., dev, staging, prod)"
  type        = string
}

variable "product_team" {
  description = "The team responsible for these resources"
  type        = string
  default     = "BPO-Infrastructure"
}

variable "domain_name" {
  description = "The private domain name for Route 53 (e.g., myapp.internal)"
  type        = string
}

# --- Primary Region (Singapore - ap-southeast-1) ---
variable "primary_vpc_cidr" {
  description = "The CIDR block for the Singapore VPC"
  type        = string
}

variable "primary_public_subnets" {
  description = "List of CIDR blocks for Singapore public subnets"
  type        = list(string)
}

variable "primary_private_subnets" {
  description = "List of CIDR blocks for Singapore private subnets"
  type        = list(string)
}

variable "primary_database_subnets" {
  description = "List of CIDR blocks for Singapore database subnets"
  type        = list(string)
}

# --- DR Region (Sydney - ap-southeast-2) ---
variable "dr_region" {
  description = "The AWS region for Disaster Recovery"
  type        = string
  default     = "ap-southeast-2"
}

variable "dr_vpc_cidr" {
  description = "The CIDR block for the Sydney VPC"
  type        = string
}

variable "dr_public_subnets" {
  description = "List of CIDR blocks for Sydney public subnets"
  type        = list(string)
}

variable "dr_private_subnets" {
  description = "List of CIDR blocks for Sydney private subnets"
  type        = list(string)
}

variable "dr_database_subnets" {
  description = "List of CIDR blocks for Sydney database subnets"
  type        = list(string)
}