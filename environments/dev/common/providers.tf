terraform {
  backend "s3" {
    bucket         = "terraform-state-cambridge"
    key            = "dev/common/terraform.tfstate"
    region         = "ap-southeast-1"
    profile        = "secondary-account"
    encrypt        = true
    dynamodb_table = "terraform-state-locks"
  }
}

# --- REGIONAL PROVIDERS ---

# 1. Primary Region: Singapore (Default)
# Used for your main VPC and ECS Cluster
provider "aws" {
  region  = "ap-southeast-1"
  profile = "secondary-account"
}

# 2. DR Region: Sydney
# Used for the backup VPC and RDS replicas
provider "aws" {
  alias   = "dr_region"
  region  = "ap-southeast-2"
  profile = "secondary-account"
}

# 3. Global Region: N. Virginia (US East 1)
# Specifically for CloudFront SSL Certificates
provider "aws" {
  alias   = "global_region"
  region  = "us-east-1"
  profile = "secondary-account"
}