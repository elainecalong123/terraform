output "public_zone_id" {
  value       = aws_route53_zone.main.zone_id
  description = "The ID of the public Route 53 zone for cambridgelaine.com"
}

### PRIMARY VPC

output "primary_vpc_id" {
  description = "The ID of the VPC in Singapore"
  value       = module.vpc_primary.vpc_id
}

output "primary_private_route_table_id" {
  description = "The private route table for Singapore"
  value       = module.vpc_primary.private_route_table_id
}

output "primary_public_subnets" {
  description = "Public subnets in Singapore"
  value       = module.vpc_primary.public_subnet_ids
}

output "primary_private_subnets" {
  description = "Private subnets in Singapore"
  value       = module.vpc_primary.private_subnet_ids
}

output "primary_database_subnet_ids" {
  description = "Database subnets in Singapore"
  value       = module.vpc_primary.database_subnet_ids
}

output "primary_vpc_cidr" {
  description = "The CIDR block of the Singapore VPC"
  value       = module.vpc_primary.vpc_cidr_block
}


### DISASTER RECOVERY VPC
output "dr_vpc_id" {
  description = "The ID of the VPC in Sydney"
  value       = module.vpc_dr.vpc_id
}

output "dr_private_route_table_id" {
  description = "The private route table for Sydney"
  value       = module.vpc_dr.private_route_table_id
}

output "dr_database_subnet_ids" {
  description = "Database subnets in Sydney"
  value       = module.vpc_dr.database_subnet_ids
}

output "dr_public_subnets" {
  description = "List of Public Subnet IDs in Sydney"
  value       = module.vpc_dr.public_subnet_ids
}

output "dr_private_subnets" {
  description = "List of Private Subnet IDs in Sydney"
  value       = module.vpc_dr.private_subnet_ids
}

output "db_arn" {
  description = "The ARN of the primary RDS instance (needed for DR replication)"
  value       = module.data.db_arn
}

output "dr_db_arn" {
  description = "The ARN of the DR RDS instance"
  value       = module.data.dr_db_arn
}

output "redis_arn" {
  description = "The ARN of the Redis replication group"
  value       = module.data.redis_arn
}

output "db_host" {
  description = "The hostname of the RDS primary instance"
  value       = module.data.db_host
}

output "redis_host" {
  description = "The hostname of the RDS dr instance"
  value       = module.data.redis_host
}