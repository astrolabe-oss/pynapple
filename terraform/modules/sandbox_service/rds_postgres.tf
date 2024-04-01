module "db_postgres" {
  source = "terraform-aws-modules/rds/aws"

  identifier = "${local.env_app_name}-db"

  engine            = "postgres"
  engine_version    = "14.11"
  instance_class    = "db.t3.micro"
  allocated_storage = 5

  db_name  = var.app_db_name
  username = "dbadmin"
  password = "Auto Created and Stored in AWS Secrets Manager:rds"
  port     = "5432"

  vpc_security_group_ids = [aws_security_group.rds_access.id]
  maintenance_window     = "Mon:00:00-Mon:03:00"
  backup_window          = "03:00-06:00"
  deletion_protection    = true
  publicly_accessible    = false

  # DB subnet group
  create_db_subnet_group = true
  subnet_ids             = var.database_subnets

  create_db_parameter_group = false

  tags = var.common_tags
}
