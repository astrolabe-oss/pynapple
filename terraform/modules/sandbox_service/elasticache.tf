locals {
  cache_engine_versions = {
    redis     = "7.1"
    memcached = "1.6.22"
  }
  cache_engine_param_groups = {
    redis     = "redis7"
    memcached = "memcached1.6"
  }
}


module "cache" {
  source = "terraform-aws-modules/elasticache/aws"

  cluster_id               = "${local.env_app_name}-cache"
  create_cluster           = true
  create_replication_group = false
  num_cache_nodes          = 1

  engine         = var.cache_engine
  engine_version = lookup(local.cache_engine_versions, var.cache_engine, "")
  node_type      = "cache.t4g.micro"

  maintenance_window = "sun:05:00-sun:09:00"
  apply_immediately  = true

  # Networking
  subnet_ids           = var.private_subnets
  vpc_id               = var.vpc_id
  security_group_rules = {
    ingress_vpc = {
      description = "VPC traffic"
      cidr_ipv4   = var.vpc_cidr_block
    }
  }

  # We don't need no stinkin' this stuff
  create_parameter_group     = false
  transit_encryption_enabled = false

  # Tags
  tags = var.common_tags
}