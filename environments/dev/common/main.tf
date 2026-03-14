# ==============================================================================
# COMMON INFRASTRUCTURE - DEV ENVIRONMENT
# Centralized Networking, DNS, and Shared RDS
# ==============================================================================

# 1. Primary VPC (Singapore)
module "vpc_primary" {
  source = "../../../modules/networking"

  env              = var.env
  vpc_cidr         = var.primary_vpc_cidr
  product_team     = var.product_team
  public_subnets   = var.primary_public_subnets
  private_subnets  = var.primary_private_subnets
  database_subnets = var.primary_database_subnets
}

# 2. DR VPC (Sydney)
module "vpc_dr" {
  source = "../../../modules/networking"
  providers = {
    aws = aws.dr_region
  }

  env              = var.env
  vpc_cidr         = var.dr_vpc_cidr
  product_team     = var.product_team
  public_subnets   = var.dr_public_subnets
  private_subnets  = var.dr_private_subnets
  database_subnets = var.dr_database_subnets
}

# 3. VPC Peering (SG <-> SYD)
module "vpc_peering" {
  source = "../../../modules/peering"
  providers = {
    aws.primary = aws
    aws.dr      = aws.dr_region
  }

  env                     = var.env
  primary_vpc_id          = module.vpc_primary.vpc_id
  dr_vpc_id               = module.vpc_dr.vpc_id
  primary_vpc_cidr        = var.primary_vpc_cidr
  dr_vpc_cidr             = var.dr_vpc_cidr
  dr_region               = "ap-southeast-2"

  primary_route_table_ids = [module.vpc_primary.private_route_table_id]
  dr_route_table_ids      = [module.vpc_dr.private_route_table_id]
}

# 4. Private DNS (Associated with both VPCs for failover)
resource "aws_route53_zone" "main" {
  name = var.domain_name

  vpc {
    vpc_id = module.vpc_primary.vpc_id
  }

  vpc {
    vpc_id     = module.vpc_dr.vpc_id
    vpc_region = "ap-southeast-2"
  }

  tags = {
    Name        = "Private-Zone"
    Environment = var.env
  }
}

# 5. Shared RDS Instance & Redis (Self-contained Data Layer)
# Note: Security Module removed to allow per-app SG management
module "data" {
  source = "../../../modules/data"

  providers = {
    aws           = aws
    aws.dr_region = aws.dr_region
  }

  env      = var.env
  app_name = "shared-rds"

  # Networking - Direct references
  vpc_id           = module.vpc_primary.vpc_id
  dr_vpc_id        = module.vpc_dr.vpc_id
  primary_vpc_cidr = var.primary_vpc_cidr
  vpn_cidr         = var.vpn_cidr

  # Subnets
  db_subnet_ids    = module.vpc_primary.database_subnet_ids
  dr_db_subnet_ids = module.vpc_dr.database_subnet_ids

  # DB Configurations (Variables)
  db_engine               = var.db_engine
  db_instance_class       = var.db_instance_class
  db_username             = var.db_username
  db_password             = var.db_password
  db_allocated_storage    = var.db_allocated_storage

  # Redis Configurations
  redis_node_type      = var.redis_node_type
}