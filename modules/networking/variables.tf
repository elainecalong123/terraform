variable "env" {
  type        = string
  description = "The deployment environment (e.g., dev, stage, prod)."
}

variable "product_team" {
  type        = string
  description = "The team responsible for the resource (e.g., Customer Solutions)."
  default     = "Customer Solutions"
}

variable "vpc_cidr" {
  type        = string
  description = "The IP range for the VPC."
  default     = "10.0.0.0/16"
}

variable "public_subnets" {
  type        = list(string)
  description = "A list of CIDR blocks for the public subnets (where ALBs live)."
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnets" {
  type        = list(string)
  description = "A list of CIDR blocks for the private subnets (where ECS tasks live)."
  default     = ["10.0.10.0/24", "10.0.11.0/24"]
}

variable "database_subnets" {
  type        = list(string)
  description = "A list of CIDR blocks for the database subnets (where RDS/Redis live)."
  default     = ["10.0.20.0/24", "10.0.21.0/24"]
}