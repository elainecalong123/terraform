# 1. Certificates (SSL/TLS)
module "certificate" {
  source = "../../../modules/certificate"
  providers = {
    aws.global = aws.global_region
  }

  env               = var.env
  app_name          = var.app_name
  domain_name       = var.domain_name
  public_zone_id    = data.terraform_remote_state.common.outputs.public_zone_id

}

# 2. IAM (Roles & Permissions)
module "iam" {
  source   = "../../../modules/iam"
  env      = var.env
  app_name = var.app_name
  aws_account_id    =  var.aws_account_id
  db_username       =  var.db_username
  redis_cluster_arn =  data.terraform_remote_state.common.outputs.redis_arn
  primary_db_arn    =  data.terraform_remote_state.common.outputs.db_arn
  dr_db_arn         =  data.terraform_remote_state.common.outputs.dr_db_arn
}

# 3. Security (Firewalls)
module "security" {
  source = "../../../modules/security"

  providers = {
    aws           = aws            # Singapore
    aws.dr_region = aws.dr_region  # Sydney
  }

  env                = var.env
  app_name           = var.app_name
  vpc_id             = data.terraform_remote_state.common.outputs.primary_vpc_id
  dr_vpc_id          = data.terraform_remote_state.common.outputs.dr_vpc_id
  vpn_cidr           = var.vpn_cidr
  primary_vpc_cidr   = data.terraform_remote_state.common.outputs.primary_vpc_cidr
}

# 4. Storage (S3 Buckets)
module "storage" {
  source = "../../../modules/storage"

  env         = var.env
  app_name        = var.app_name
  cloudfront_arn = module.edge.cloudfront_arn
}

# 5. Compute (ALB & ECS)

module "compute" {
  source = "../../../modules/compute"

  env                    = var.env
  app_name               = var.app_name
  container_image        = var.container_image
  db_username            = var.db_username
  vpc_id                 = data.terraform_remote_state.common.outputs.primary_vpc_id
  public_subnet_ids      = data.terraform_remote_state.common.outputs.primary_public_subnets
  private_subnet_ids     = data.terraform_remote_state.common.outputs.primary_private_subnets

  alb_sg_id              = module.security.alb_sg_id
  ecs_sg_id              = module.security.ecs_sg_id
  execution_role_arn     = module.iam.execution_role_arn
  task_role_arn          = module.iam.task_role_arn
  acm_certificate_arn    = module.certificate.certificate_arn
  db_host                = data.terraform_remote_state.common.outputs.db_host
  redis_host             = data.terraform_remote_state.common.outputs.redis_host
  db_password_secret_arn = data.terraform_remote_state.common.outputs.db_password_secret_arn
}

# 6. Edge (CloudFront CDN)
module "edge" {
  source = "../../../modules/edge"

  providers = {
      aws.global_region = aws.global_region
  }

  domain_name = var.domain_name

  env             = var.env
  app_name        = var.app_name
  alb_dns_name    = module.compute.alb_dns_name
  s3_bucket_regional_domain_name    = module.storage.s3_bucket_regional_domain_name
  acm_certificate_arn = module.certificate.certificate_arn
  public_zone_id = data.terraform_remote_state.common.outputs.public_zone_id
}