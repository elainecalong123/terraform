# ==============================================================================
# DATA MODULE - SHARED RDS & REDIS
# Handles Database, Cache, and associated Security Groups for Primary & DR
# ==============================================================================

locals {
  common_tags = {
    Environment = var.env
    Application = var.app_name
    ManagedBy   = "Terraform"
  }
}

# --- PRIMARY REGION (Singapore) ---

resource "aws_security_group" "db" {
  name        = "${var.app_name}-${var.env}-db-sg"
  description = "Data layer security for Primary Region"
  vpc_id      = var.vpc_id

  # Consolidated Ingress for Postgres
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.vpn_cidr]
    description = "Allow Postgres from Singapore VPC and VPN"
  }

  ingress {
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = [var.primary_vpc_cidr]
    description = "Allow Redis from Singapore VPC"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, { Name = "${var.app_name}-db-sg" })
}

# 2. Primary RDS Instance
resource "aws_db_instance" "primary" {
  identifier           = "${var.app_name}-${var.env}-primary"
  allocated_storage    = var.db_allocated_storage
  engine               = var.db_engine
  instance_class       = var.db_instance_class
  db_subnet_group_name = aws_db_subnet_group.db_group.name
  storage_encrypted = true
  parameter_group_name = aws_db_parameter_group.postgres_sg.name
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
  kms_key_id          = aws_kms_key.primary_rds.arn
  vpc_security_group_ids = [aws_security_group.db.id]
  multi_az             = var.env == "prod" ? true : false
  db_name              = replace(var.app_name, "-", "_")
  username             = var.db_username
  password             = var.db_password
  iam_database_authentication_enabled = true
  skip_final_snapshot                 = var.env == "prod" ? false : true
  backup_retention_period = var.db_backup_retention_period
  backup_window           = var.db_backup_window
  apply_immediately = true
  tags = merge(local.common_tags, { Name = "${var.app_name}-primary" })
}

# 3. Redis Replication Group
resource "aws_elasticache_replication_group" "redis" {
  replication_group_id          = "${var.app_name}-${var.env}-redis"
  description                   = "Redis cluster for ${var.app_name}"
  node_type                     = var.redis_node_type
  num_cache_clusters            = var.env == "prod" ? 3 : 2
  port                          = 6379
  subnet_group_name             = aws_elasticache_subnet_group.redis_group.name

  security_group_ids            = [aws_security_group.db.id]
  automatic_failover_enabled    = true

  tags = local.common_tags
}

# 4. Primary Subnet Groups
resource "aws_db_subnet_group" "db_group" {
  name       = "${var.app_name}-${var.env}-db-subnets"
  subnet_ids = var.db_subnet_ids
}

resource "aws_elasticache_subnet_group" "redis_group" {
  name       = "${var.app_name}-${var.env}-redis-subnets"
  subnet_ids = var.db_subnet_ids
}

# --- DR REGION (Sydney) ---

# 5. DR Database Security Group
resource "aws_security_group" "dr_db" {
  provider    = aws.dr_region
  name        = "${var.app_name}-${var.env}-dr-db-sg"
  description = "Data layer security for Sydney Region"
  vpc_id      = var.dr_vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    # Removes duplicates if VPN and VPC CIDRs are the same
    cidr_blocks = distinct([var.primary_vpc_cidr, var.vpn_cidr])
    description = "Allow replication and VPN access"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, { Name = "${var.app_name}-dr-db-sg" })
}

# 6. DR Read Replica (Sydney)
resource "aws_db_instance" "dr_replica" {
  provider               = aws.dr_region
  identifier             = "${var.app_name}-${var.env}-dr-replica"
  replicate_source_db    = aws_db_instance.primary.arn
  depends_on = [aws_db_instance.primary]
  instance_class         = var.db_instance_class
  db_subnet_group_name   = aws_db_subnet_group.db_group_dr.name
  storage_encrypted = true
  parameter_group_name = aws_db_parameter_group.postgres_syd.name
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
  kms_key_id             = aws_kms_key.dr_rds.arn
  vpc_security_group_ids = [aws_security_group.dr_db.id]
  multi_az               = false
  skip_final_snapshot    = true
  backup_retention_period = var.dr_db_backup_retention_period
  backup_window           = var.db_backup_window
  tags = merge(local.common_tags, { Name = "${var.app_name}-dr-replica" })
}

# 7. DR Subnet Group
resource "aws_db_subnet_group" "db_group_dr" {
  provider   = aws.dr_region
  name       = "${var.app_name}-${var.env}-db-subnets-dr"
  subnet_ids = var.dr_db_subnet_ids
}

# 8. INTERNAL DNS (Private Hosted Zone)
resource "aws_route53_zone" "internal" {
  name = var.internal_domain_name

  vpc {
    vpc_id = var.vpc_id
  }

  vpc {
    vpc_id     = var.dr_vpc_id
    vpc_region = "ap-southeast-2"
  }

  tags = local.common_tags
}

# Database Record (e.g., db-dev.cambridgelaine.internal)
resource "aws_route53_record" "rds_internal" {
  zone_id = aws_route53_zone.internal.zone_id
  name    = "db-${var.env}.${var.internal_domain_name}"
  type    = "CNAME"
  ttl     = "300"
  records = [aws_db_instance.primary.address]
}

# Database Record for dr(e.g., db-dr-dev.cambridgelaine.internal)
resource "aws_route53_record" "rds_dr_internal" {
  zone_id = aws_route53_zone.internal.zone_id
  name    = "db-dr-${var.env}.${var.internal_domain_name}" # db-dr-dev...
  type    = "CNAME"
  ttl     = "300"
  records = [aws_db_instance.dr_replica.address]
}

# Redis Record (e.g., redis-dev.cambridgelaine.internal)
resource "aws_route53_record" "redis_internal" {
  zone_id = aws_route53_zone.internal.zone_id
  name    = "redis-${var.env}.${var.internal_domain_name}"
  type    = "CNAME"
  ttl     = "300"
  records = [aws_elasticache_replication_group.redis.primary_endpoint_address]
}


# KMS Key in Singapore (Primary)
resource "aws_kms_key" "primary_rds" {
  description             = "KMS key for Primary RDS encryption"
  deletion_window_in_days = 10
  enable_key_rotation     = true
  tags                    = local.common_tags
}

# KMS Key in Sydney (DR)
resource "aws_kms_key" "dr_rds" {
  provider                = aws.dr_region
  description             = "KMS key for DR RDS encryption"
  deletion_window_in_days = 10
  enable_key_rotation     = true
  tags                    = local.common_tags
}

# parameter group

# --- Singapore Parameter Group ---
resource "aws_db_parameter_group" "postgres_sg" {
  name   = "${var.app_name}-${var.env}-pg-params"
  family = "postgres17"

  dynamic "parameter" {
    for_each = var.rds_custom_parameters
    content {
      name  = parameter.value.name
      value = parameter.value.value
    }
  }
}

# --- Sydney Parameter Group ---
resource "aws_db_parameter_group" "postgres_syd" {
  provider = aws.dr_region # Build this in Sydney
  name     = "${var.app_name}-${var.env}-pg-params-dr"
  family   = "postgres17"

  dynamic "parameter" {
    for_each = var.rds_custom_parameters
    content {
      name  = parameter.value.name
      value = parameter.value.value
    }
  }
}