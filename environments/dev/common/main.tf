# 1. Primary VPC (Singapore)
module "vpc_primary" {
  source = "../../../modules/networking"

  env              = var.env
  vpc_cidr         = var.primary_vpc_cidr
  product_team     = var.product_team
  # Using variables instead of hardcoded IPs
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
  # Using variables for DR region
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

  # Secondary VPC association for DR
  vpc {
    vpc_id     = module.vpc_dr.vpc_id
    vpc_region = "ap-southeast-2"
  }

  tags = {
    Name        = "Private-Zone"
    Environment = var.env
  }
}