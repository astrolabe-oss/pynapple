locals {
  db_admin = "dbadmin"
  db_engine_versions = {
    postgres = "14.12"
    mysql    = "8.0.35"
  }
  db_engine_protocols = {
    postgres = "postgresql"
    mysql    = "mysql+pymysql"
  }
  database_conn_str = "${lookup(local.db_engine_protocols, var.database_engine, "")}://${var.app_name}:${aws_secretsmanager_secret_version.application_db_user_pass.secret_string}@${module.rdbms.db_instance_endpoint}/${var.app_db_name}"
}

module "rdbms" {
  source = "terraform-aws-modules/rds/aws"

  identifier = "${local.env_app_name}-db"

  engine            = var.database_engine
  engine_version    = lookup(local.db_engine_versions, var.database_engine, "")
  instance_class    = "db.t3.micro"
  allocated_storage = 5

  db_name  = var.app_db_name
  username = local.db_admin
  #password = "Auto Created and Stored in AWS Secrets Manager:rds"
  #port     = "5432" # should be automaticaly selected based on engine default...

  vpc_security_group_ids = [aws_security_group.rds_access.id]
  maintenance_window     = "Mon:00:00-Mon:03:00"
  backup_window          = "03:00-06:00"
  deletion_protection    = true
  publicly_accessible    = true # this is so we provision db user via terraform below

  # DB subnet group
  create_db_subnet_group = true
  subnet_ids             = var.database_subnets

  create_db_parameter_group = false
  create_db_option_group    = false

  tags = var.common_tags
}
