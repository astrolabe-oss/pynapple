module "pynapple2" {
  source = "./modules/sandbox_service"

  # app
  env_name = local.env_name
  app_name = "pynapple2"

  # networking
  vpc_id                     = module.vpc.vpc_id
  vpc_cidr_block             = module.vpc.vpc_cidr_block
  public_subnets             = module.vpc.public_subnets
  private_subnets            = module.vpc.private_subnets
  database_subnets           = module.vpc.database_subnets
  key_pair_name              = aws_key_pair.infra_2024_1_30_1.key_name
  ip_addresses_devs          = local.ip_addresses_devs
  eks_node_security_group_id = module.eks.node_security_group_id
  security_group_ids = [
    aws_security_group.allow_ssh.id,
    module.vpc.default_security_group_id
  ]

  # components
  app_db_name     = "pynapple"
  database_engine = "mysql"
  cache_engine    = "memcached"
  common_env_vars = [
    {
      name  = "FLASK_ENV"
      value = "development"
    }
  ]

  # tags
  common_tags = local.common_tags
}
