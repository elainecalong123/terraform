locals {
  common_tags = {
    Environment  = var.env
    ProductTeam  = var.product_team
    Application  = var.app_name
    ManagedBy    = "Terraform"
  }
  # Placeholder for VPN CIDR - move to variables.tf in the next step
  vpn_cidr = "10.50.0.0/16"
}

# 1. ALB Security Group
resource "aws_security_group" "alb" {
  name        = "${var.app_name}-${var.env}-alb-sg"
  description = "Controls internet traffic to the ALB"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, { Name = "${var.app_name}-${var.env}-alb-sg" })
}

# 2. ECS Task Security Group
resource "aws_security_group" "ecs_tasks" {
  name        = "${var.app_name}-${var.env}-ecs-sg"
  description = "Application layer security"
  vpc_id      = var.vpc_id

  # Traffic from the ALB
  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.alb.id]
  }

  # Direct access for DevOps Engineers via VPN
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [local.vpn_cidr]
    description = "Allow DevOps access via VPN"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, { Name = "${var.app_name}-${var.env}-ecs-sg" })
}

# 3. Database Security Group
resource "aws_security_group" "db" {
  name        = "${var.app_name}-${var.env}-db-sg"
  description = "Data layer security"
  vpc_id      = var.vpc_id

  # RDS Access from ECS tasks
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_tasks.id]
  }

  # Redis Access from ECS tasks
  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol    = "tcp"
    security_groups = [aws_security_group.ecs_tasks.id]
  }

  # Direct Database access for DevOps via VPN (for DB administration)
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [local.vpn_cidr]
    description = "Allow DevOps DB admin via VPN"
  }

  tags = merge(local.common_tags, { Name = "${var.app_name}-${var.env}-db-sg" })
}

# --- DR REGION (Sydney) ---

# 4. DR Database Security Group
resource "aws_security_group" "dr_db" {
  provider    = aws.dr_region # Deploys to Sydney
  name        = "${var.app_name}-${var.env}-dr-db-sg"
  description = "Data layer security for DR Region"
  vpc_id      = var.dr_vpc_id # Must use the Sydney VPC ID

  # Allow Primary ECS Tasks (Singapore) to talk to DR DB (Sydney)
  # Required for cross-region replication/initialization
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.primary_vpc_cidr] # CIDR of Singapore VPC
    description = "Allow replication from Singapore VPC"
  }

  # Allow DevOps via VPN
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [local.vpn_cidr]
    description = "Allow DevOps DB admin via VPN"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, { Name = "${var.app_name}-${var.env}-dr-db-sg" })
}