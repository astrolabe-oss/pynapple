output "pynapple1_load_balancer_dns_name" {
  value = module.pynapple1.load_balancer_dns_name
}

output "pynapple1_load_balancer_zone_id" {
  value = module.pynapple1.load_balancer_zone_id
}

output "pynapple1_ecr_repo_url" {
  value = module.pynapple1.ecr_repo_arn
}

output "pynapple2_load_balancer_dns_name" {
  value = module.pynapple2.load_balancer_dns_name
}

output "pynapple2_load_balancer_zone_id" {
  value = module.pynapple2.load_balancer_zone_id
}

output "pynapple2_ecr_repo_url" {
  value = module.pynapple2.ecr_repo_arn
}