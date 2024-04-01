output "pynapple_alb_dns_name" {
  value = module.alb.dns_name
}

output "pynapple_alb_zone_id" {
  value = module.alb.zone_id
}

output "pynapple1_load_balancer_dns_name" {
  value = module.pynapple1.load_balancer_dns_name
}

output "pynapple1_rds_postgres_host" {
  value = module.pynapple1.rds_postgres_host
}

output "pynapple1_elasticache_redis_host" {
  value       = module.pynapple1.elasticache_redis_host
}