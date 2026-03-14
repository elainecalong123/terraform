env              = "dev"
domain_name = "cambridgelaine.com"
# Primary Region (Singapore)
primary_vpc_cidr         = "10.0.0.0/16"
primary_public_subnets   = ["10.0.1.0/24", "10.0.2.0/24"]
primary_private_subnets  = ["10.0.10.0/24", "10.0.11.0/24"]
primary_database_subnets = ["10.0.20.0/24", "10.0.21.0/24"]

# DR Region (Sydney)
dr_vpc_cidr         = "10.1.0.0/16"
dr_public_subnets   = ["10.1.1.0/24", "10.1.2.0/24"]
dr_private_subnets  = ["10.1.10.0/24", "10.1.11.0/24"]
dr_database_subnets = ["10.1.20.0/24", "10.1.21.0/24"]