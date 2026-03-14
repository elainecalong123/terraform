# 1. Trust Policy for ECS Tasks
# This tells AWS that ECS Fargate is allowed to 'wear' these roles.
data "aws_iam_policy_document" "ecs_task_trust" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# 2. Local Tags for Consistency
# We include the 'Application' tag so you can filter costs and logs by app name.
locals {
  common_tags = {
    Environment  = var.env
    ProductTeam  = var.product_team
    Application  = var.app_name
    ManagedBy    = "Terraform"
  }
}

# 3. ECS Execution Role
# This is the 'System Role'. The ECS agent needs this to pull images from ECR
# and stream logs to CloudWatch.
resource "aws_iam_role" "execution_role" {
  name               = "${var.app_name}-${var.env}-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_trust.json

  tags = merge(local.common_tags, {
    Name = "${var.app_name}-${var.env}-execution-role"
  })
}

# Attaches the AWS-managed policy required for basic ECS operations.
resource "aws_iam_role_policy_attachment" "execution_policy" {
  role       = aws_iam_role.execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# 4. ECS Task Role
# This is the 'Application Role'. Your code uses this identity to
# interact with AWS services like RDS and Redis.
resource "aws_iam_role" "task_role" {
  name               = "${var.app_name}-${var.env}-task-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_trust.json

  tags = merge(local.common_tags, {
    Name = "${var.app_name}-${var.env}-task-role"
  })
}

# 5. RDS Primary/DR + Redis IAM
resource "aws_iam_role_policy" "data_silo_access" {
  name = "${var.app_name}-${var.env}-data-access"
  role = aws_iam_role.task_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        # Database Isolation: Grants access to Primary and DR ARNs
        Effect   = "Allow"
        Action   = [
          "rds-db:connect",
          "rds:DescribeDBInstances"
        ]
        Resource = [
                  var.primary_db_arn,
                  var.dr_db_arn
        ]
      },
      {
        # Redis/ElastiCache Isolation
        Effect   = "Allow"
        Action   = [
          "elasticache:Connect",
          "elasticache:DescribeReplicationGroups",
          "elasticache:DescribeCacheClusters"
        ]
        Resource = [var.redis_cluster_arn]
      }
    ]
  })
}