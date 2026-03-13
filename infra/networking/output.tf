output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = aws_subnet.public[*].id
}

output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = aws_subnet.private[*].id
}

output "nat_gateway_ip" {
  description = "The public IP of the NAT Gateway"
  value       = aws_eip.nat.public_ip
}

output "ssm_path_prefix" {
  description = "The prefix where networking data is stored for apps"
  value       = "/infra/${var.environment}/"
}