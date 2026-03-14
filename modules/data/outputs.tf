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