output "rds_endpoint" {
  description = "Primary RDS Writer Endpoint"
  value       = aws_db_instance.primary.address
}

output "rds_dr_endpoint" {
  description = "DR Replica Endpoint in us-east-2"
  value       = var.enable_dr_replica ? aws_db_instance.dr_replica[0].address : "none"
}

output "redis_endpoint" {
  description = "Redis Primary Endpoint"
  value       = aws_elasticache_replication_group.redis.primary_endpoint_address
}