# --- 1. RDS SUBNET GROUPS ---

# Primary Subnet Group (us-east-1) - Uses your 2 AZs
resource "aws_db_subnet_group" "primary" {
  name       = "${var.app_name}-${var.environment}-rds-subnets"
  subnet_ids = var.private_subnets
}

# DR Subnet Group (us-east-2) - Needs to be created in the DR region
resource "aws_db_subnet_group" "dr" {
  provider   = aws.dr
  name       = "${var.app_name}-${var.environment}-dr-subnets"
  subnet_ids = var.dr_private_subnets # These come from your us-east-2 VPC
}

# --- 2. PRIMARY RDS INSTANCE (us-east-1) ---

resource "aws_db_instance" "primary" {
  identifier            = "${var.app_name}-${var.environment}-db"
  db_name               = var.db_name
  engine                = var.db_engine
  engine_version        = var.db_engine_version
  instance_class        = var.db_instance_class
  allocated_storage     = var.db_allocated_storage
  max_allocated_storage = var.db_max_storage

  username = "dbadmin"
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.primary.name
  vpc_security_group_ids = [var.rds_sg_id]

  # High Availability across your 2 AZs
  multi_az               = var.multi_az

  # Required for Cross-Region Replication
  backup_retention_period = 7
  skip_final_snapshot     = var.environment != "prod"
}

# --- 3. DISASTER RECOVERY REPLICA (us-east-2) ---

resource "aws_db_instance" "dr_replica" {
  count               = var.enable_dr_replica ? 1 : 0
  provider            = aws.dr
  identifier          = "${var.app_name}-${var.environment}-db-dr"
  replicate_source_db = aws_db_instance.primary.arn # Cross-region ARN link

  instance_class         = var.dr_instance_class
  db_subnet_group_name   = aws_db_subnet_group.dr.name
  vpc_security_group_ids = [var.dr_rds_sg_id]

  parameter_group_name = aws_db_instance.primary.parameter_group_name
  skip_final_snapshot  = true
}

# --- 4. REDIS (ELASTICACHE) ---

resource "aws_elasticache_subnet_group" "redis" {
  name       = "${var.app_name}-${var.environment}-redis-subnets"
  subnet_ids = var.private_subnets
}

resource "aws_elasticache_replication_group" "redis" {
  replication_group_id          = "${var.app_name}-${var.environment}-redis"
  replication_group_description = "Redis for ${var.app_name}"

  node_type            = var.redis_node_type
  engine_version       = var.redis_engine_version
  port                 = 6379
  parameter_group_name = "default.redis7"

  # HA setup for 2 AZs
  multi_az_enabled           = var.redis_multi_az_enabled
  automatic_failover_enabled = true
  num_cache_clusters         = var.redis_num_clusters

  subnet_group_name  = aws_elasticache_subnet_group.redis.name
  security_group_ids = [var.redis_sg_id]
}