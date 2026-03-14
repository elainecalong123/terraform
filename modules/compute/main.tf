locals {
  common_tags = {
    Environment = var.env
    Application = var.app_name
    ManagedBy   = "Terraform"
  }
}

# 1. Application Load Balancer (external)
resource "aws_lb" "main" {
  name               = "${var.app_name}-${var.env}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_sg_id]
  subnets            = var.public_subnet_ids

  tags = local.common_tags
}

# 2. HTTPS Listener (Secure)
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.main.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = var.acm_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}

# 3. HTTP Listener (Redirect to HTTPS)
resource "aws_lb_listener" "http_redirect" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# 4. Target Group (UPDATED FOR TLS)
resource "aws_lb_target_group" "app" {
  name        = "${var.app_name}-${var.env}-tg"
  port        = 443      # Changed to secure port
  protocol    = "HTTPS"  # FORCED RE-ENCRYPTION
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = "/health"
    protocol            = "HTTPS" # Health check must also be secure
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}

# 5. ECS Task Definition (UPDATED FOR TLS)
resource "aws_ecs_task_definition" "app" {
  family                   = "${var.app_name}-${var.env}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([
    {
      name      = var.app_name
      image     = var.container_image
      essential = true
      portMappings = [
        {
          containerPort = 443 # Matching Target Group
          hostPort      = 443
        }
      ]
      environment = [
        { name = "DB_HOST", value = var.db_host },
        { name = "REDIS_HOST", value = var.redis_host },
        # FORCING DATABASE TLS CONNECTION
        { name = "DB_SSL_MODE", value = "require" }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/${var.app_name}-${var.env}"
          "awslogs-region"        = "ap-southeast-1"
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
}

# 6. ECS Service
resource "aws_ecs_service" "main" {
  name            = "${var.app_name}-service"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = var.private_subnet_ids
    security_groups = [var.ecs_sg_id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.app.arn
    container_name   = var.app_name
    container_port   = 443 # Updated to match container definition
  }
}

# 7. ECS Cluster
resource "aws_ecs_cluster" "this" {
  name = "${var.env}-${var.app_name}-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}