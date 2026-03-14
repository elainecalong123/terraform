output "alb_sg_id" {
  description = "The Security Group ID for the Application Load Balancer"
  value       = aws_security_group.alb.id
}

output "ecs_sg_id" {
  description = "The Security Group ID for the ECS Fargate tasks"
  value       = aws_security_group.ecs_tasks.id
}
