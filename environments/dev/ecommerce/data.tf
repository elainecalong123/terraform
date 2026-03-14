data "terraform_remote_state" "common" {
  backend = "s3"
  config = {
    bucket  = "terraform-state-cambridge"
    key     = "dev/common/terraform.tfstate"
    region  = "ap-southeast-1"
    profile = "secondary-account"
  }
}