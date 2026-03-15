locals {
  common_tags = {
    Environment  = var.env
    ProductTeam  = var.product_team
    Application  = var.app_name
    ManagedBy    = "Terraform"
  }
}

# 1. Trust Policy (Same as before)
data "aws_iam_policy_document" "ecs_task_trust" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# 2. ECS Execution Role (The "System" Role)
# ECS uses this to pull images and fetch secrets BEFORE the app starts.
resource "aws_iam_role" "execution_role" {
  name               = "${var.app_name}-${var.env}-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_trust.json
  tags               = local.common_tags
}

resource "aws_iam_role_policy_attachment" "execution_policy" {
  role       = aws_iam_role.execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# IMPORTANT: Execution role needs this to read secrets for environment variable injection
resource "aws_iam_role_policy" "execution_secrets" {
  name = "${var.app_name}-${var.env}-execution-secrets"
  role = aws_iam_role.execution_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["secretsmanager:GetSecretValue", "kms:Decrypt"]
        Resource = ["*"] # You can restrict this to your specific Secret ARNs
      }
    ]
  })
}

# 3. ECS Task Role (The "Application" Role)
# Your code uses this to connect to the DB and Redis while running.
resource "aws_iam_role" "task_role" {
  name               = "${var.app_name}-${var.env}-task-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_trust.json
  tags               = local.common_tags
}

resource "aws_iam_role_policy" "task_data_access" {
  name = "${var.app_name}-${var.env}-task-data-access"
  role = aws_iam_role.task_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        # RDS IAM Authentication (Proper Resource Format)
        Effect   = "Allow"
        Action   = ["rds-db:connect"]
        Resource = [
          "arn:aws:rds-db:ap-southeast-1:${var.aws_account_id}:dbuser:*/${var.db_username}"
        ]
      },
      {
        # Redis / ElastiCache Access
        Effect   = "Allow"
        Action   = ["elasticache:Connect", "elasticache:Describe*"]
        Resource = ["*"]
      },
      {
        # App might need to read secrets at runtime (SDK calls)
        Effect   = "Allow"
        Action   = ["secretsmanager:GetSecretValue"]
        Resource = ["*"]
      }
    ]
  })
}