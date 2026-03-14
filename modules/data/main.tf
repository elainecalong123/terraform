locals {
  common_tags = {
    Environment = var.env
    Application = var.app_name
    ManagedBy   = "Terraform"
  }
}

# Primary RDS with Standby (Multi-AZ)
resource "aws_db_instance" "primary" {
  identifier           = "${var.app_name}-${var.env}-primary"
  allocated_storage    = 20
  engine               = var.db_engine
  instance_class       = var.db_instance_class
  db_subnet_group_name = aws_db_subnet_group.db_group.name
  vpc_security_group_ids = [var.db_security_group_id]

  multi_az             = true
  db_name              = replace(var.app_name, "-", "_")
  username             = "dbadmin"
  password             = "REPLACE_ME_VIA_SECRETS_MANAGER"

  iam_database_authentication_enabled = true
  skip_final_snapshot  = true

  tags = merge(local.common_tags, { Name = "${var.app_name}-primary" })
}

# Redis Cluster
resource "aws_elasticache_replication_group" "redis" {
  replication_group_id          = "${var.app_name}-${var.env}-redis"
  description                   = "Redis for ${var.app_name}"
  node_type                     = "cache.t3.micro"
  num_cache_clusters            = 2
  port                          = 6379
  subnet_group_name             = aws_elasticache_subnet_group.redis_group.name
  security_group_ids            = [var.db_security_group_id]
  automatic_failover_enabled    = true

  tags = local.common_tags
}

resource "aws_db_subnet_group" "db_group" {
  name       = "${var.app_name}-${var.env}-db-subnets"
  subnet_ids = var.db_subnet_ids
}


resource "aws_elasticache_subnet_group" "redis_group" {
  name       = "${var.app_name}-${var.env}-redis-subnets"
  subnet_ids = var.db_subnet_ids
}

### DR Region (Sydney)
# Subnet group in Sydney
resource "aws_db_subnet_group" "db_group_dr" {
  provider   = aws.dr_region
  name       = "${var.app_name}-${var.env}-db-subnets-dr"
  subnet_ids = var.dr_db_subnet_ids
}

# The DR Read Replica
resource "aws_db_instance" "dr_replica" {
  provider               = aws.dr_region
  identifier             = "${var.app_name}-${var.env}-dr-replica"

  # Point this to the Primary ARN
  replicate_source_db    = aws_db_instance.primary.arn

  instance_class         = var.db_instance_class
  db_subnet_group_name   = aws_db_subnet_group.db_group_dr.name
  vpc_security_group_ids = [var.dr_db_security_group_id]

  # Multi-AZ is optional for DR but recommended for high-tier production
  multi_az               = false
  skip_final_snapshot    = true

  tags = merge(local.common_tags, { Name = "${var.app_name}-dr-replica" })
}