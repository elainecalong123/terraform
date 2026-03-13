# 1. DISCOVER THE NETWORK
module "networking" {
  source             = "../modules/network"
  network_ssm_prefix = var.network_ssm_prefix
}

# 2. SECURITY (Uses the discovered VPC)
module "security" {
  source      = "../modules/security"
  vpc_id      = module.network.vpc_id
  app_name    = var.app_name
  environment = var.environment
  # ...
}

# 3. DATA (Uses the discovered Private Subnets)
module "data" {
  source          = "../modules/data"
  vpc_id          = module.network.vpc_id
  private_subnets = module.network.private_subnet_ids
  rds_sg_id       = module.security.rds_sg_id
  # ...
}

# 4. COMPUTE (Uses both Public and Private Subnets)
module "compute" {
  source          = "../modules/compute"
  vpc_id          = module.network.vpc_id
  public_subnets  = module.network.public_subnet_ids
  private_subnets = module.network.private_subnet_ids
  # ...
}