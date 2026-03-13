terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # This stays partial because the "key" (e.g., crm/stage) is passed
  # via -backend-config during 'terraform init'
  backend "s3" {
    bucket         = "my-terraform-state-bucket"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock"
    encrypt        = true
  }
}

# Primary Region Provider (us-east-1)
# Used for Networking, Compute, and Primary Data
provider "aws" {
  region = var.primary_region

  default_tags {
    tags = {
      Project     = var.app_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}

# Secondary/DR Region Provider (us-east-2)
# Specifically used for the RDS Cross-Region Read Replica
provider "aws" {
  alias  = "dr_region"
  region = var.secondary_region

  default_tags {
    tags = {
      Project     = var.app_name
      Environment = var.environment
      ManagedBy   = "Terraform"
      Role        = "Disaster-Recovery"
    }
  }
}