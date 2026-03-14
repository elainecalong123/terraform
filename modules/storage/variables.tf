variable "env" {
  type = string
}

variable "app_name" {
  type = string
}

variable "cloudfront_arn" {
  description = "The ARN of the CloudFront distribution allowed to access S3"
  type        = string
}