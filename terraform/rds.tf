module "db" {
  source = "terraform-aws-modules/rds/aws"

  identifier = "${local.env_app_name}-db"

  engine            = "postgres"
  engine_version    = "14.11"
  instance_class    = "db.t3.micro"
  allocated_storage = 5

  db_name  = "pynapple"
  username = "dbadmin"
  password = "AWS Secrets Manager:rds!db-c07aa402-6a86-42f5-a425-c23c8e9cf45c"
  port     = "5432"

  vpc_security_group_ids = [aws_security_group.pynapple_rds_access.id]
  maintenance_window     = "Mon:00:00-Mon:03:00"
  backup_window          = "03:00-06:00"
  deletion_protection    = true
  publicly_accessible    = false

  # DB subnet group
  create_db_subnet_group = true
  subnet_ids             = module.vpc.database_subnets

  create_db_parameter_group = false
  # Database Deletion Protection
  #  parameters = [
  #    {
  #      name  = "character_set_client"
  #      value = "utf8mb4"
  #    },
  #    {
  #      name  = "character_set_server"
  #      value = "utf8mb4"
  #    }
  #  ]

  tags = local.common_tags
}
