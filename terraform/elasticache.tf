module "cache" {
  source = "terraform-aws-modules/elasticache/aws"

  cluster_id               = "${local.env_app_name}-cache"
  create_cluster           = true
  create_replication_group = false
  num_cache_nodes          = 1

  engine_version = "7.1"
  node_type      = "cache.t4g.micro"

  maintenance_window = "sun:05:00-sun:09:00"
  apply_immediately  = true

  # Security group
  vpc_id = module.vpc.vpc_id
  security_group_rules = {
    ingress_vpc = {
      description = "VPC traffic"
      cidr_ipv4   = module.vpc.vpc_cidr_block
    }
  }

  # Subnet Group
  subnet_ids = module.vpc.private_subnets

  # Parameter Group
  create_parameter_group = true
  parameter_group_family = "redis7"
  parameters = [
    {
      name  = "latency-tracking"
      value = "yes"
    }
  ]

  tags = local.common_tags
}