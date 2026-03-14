terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = ">= 5.0"
      # 'aws' is default (Singapore), 'aws.dr' is the alias (Sydney)
      configuration_aliases = [ aws.dr_region ]
    }
  }
}