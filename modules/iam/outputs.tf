output "execution_role_arn" {
  description = "The ARN of the ECS execution role (used by the ECS agent)."
  value       = aws_iam_role.execution_role.arn
}

output "task_role_arn" {
  description = "The ARN of the ECS task role (used by the application code)."
  value       = aws_iam_role.task_role.arn
}

output "task_role_name" {
  description = "The name of the task role (useful for attaching additional policies if needed)."
  value       = aws_iam_role.task_role.name
}

output "execution_role_name" {
  description = "The name of the execution role."
  value       = aws_iam_role.execution_role.name
}