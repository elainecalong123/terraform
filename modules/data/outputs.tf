output "db_arn" {
  description = "The ARN of the primary RDS instance (needed for DR replication)"
  value       = aws_db_instance.primary.arn
}

output "dr_db_arn" {
  description = "The ARN of the DR RDS instance "
  value       = aws_db_instance.dr_replica.arn
}

output "redis_arn" {
  description = "The ARN of the Redis replication group"
  value       = aws_elasticache_replication_group.redis.arn
}

output "db_host" {
  description = "The hostname of the RDS primary instance"
  value       = aws_db_instance.primary.address
}

output "dr_db_host" {
  description = "The hostname of the RDS dr instance"
  value       = aws_db_instance.dr_replica.address
}

output "redis_host" {
  description = "The primary endpoint address for the Redis replication group"
  value       = aws_elasticache_replication_group.redis.primary_endpoint_address
}

# --- Security Outputs ---
output "db_security_group_id" {
  description = "The ID of the primary security group (needed for app ingress rules)"
  value       = aws_security_group.db.id
}

output "dr_db_security_group_id" {
  description = "The ID of the DR security group"
  value       = aws_security_group.dr_db.id
}

# --- Connection Details ---
output "db_port" {
  description = "The port the primary RDS instance is listening on"
  value       = aws_db_instance.primary.port
}

output "db_name" {
  description = "The name of the default database created"
  value       = aws_db_instance.primary.db_name
}

output "redis_port" {
  description = "The port the Redis replication group is listening on"
  value       = aws_elasticache_replication_group.redis.port
}

# --- Resource IDs (Good for monitoring/tagging) ---
output "db_resource_id" {
  description = "The RDS Resource ID"
  value       = aws_db_instance.primary.resource_id
}