terraform {
  backend "s3" {
    bucket         = "terraform-state-cambridge"
    key            = "dev/ecommerce/terraform.tfstate"
    region         = "ap-southeast-1"
    profile        = "secondary-account"
    encrypt        = true
    dynamodb_table = "terraform-state-locks"
  }
}

provider "aws" {
  region  = "ap-southeast-1"
  profile = "secondary-account"
}

# Alias for certificates (ACM requirement for CloudFront)
provider "aws" {
  alias   = "global_region"
  region  = "us-east-1"
  profile = "secondary-account"
}

provider "aws" {
  alias   = "dr_region"
  region  = "ap-southeast-1"
  profile = "secondary-account"
}