output "load_balancer_dns_name" {
  description = "The DNS name of the ALB"
  value       = module.alb.dns_name
}

output "load_balancer_zone_id" {
  description = "The DNS Zone Id of the ALB"
  value       = module.alb.zone_id
}

output "ec2_deploy_bucket" {
  description = "S3 Bucket for deploying application to EC2"
  value       = aws_s3_bucket.deploy.bucket
}

output "rds_postgres_host" {
  description = "DB Endpoint for the RDS Postgres Instance"
  value       = module.rdbms.db_instance_endpoint
}

output "elasticache_redis_host" {
  description = "Connection Endpoint for the ElastiCache Redis Instance"
  value       = module.cache.cluster_cache_nodes[0].address
}

output "ecr_repo_arn" {
  description = "ECR Repository"
  value       = aws_ecr_repository.this.repository_url
}