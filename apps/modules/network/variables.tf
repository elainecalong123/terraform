variable "network_ssm_prefix" {
  description = "The SSM path prefix for shared networking (e.g., /infra/stage)"
  type        = string
}

# Optional: Add the region if you want the module to be
# explicit about where it is looking for parameters
variable "region" {
  description = "The AWS region to search in"
  type        = string
  default     = "us-east-1"
}