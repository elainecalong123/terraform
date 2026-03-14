terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = ">= 5.0"
      # We only list the alias here. The default 'aws' is inherited automatically.
      configuration_aliases = [ aws.global ]
    }
  }
}