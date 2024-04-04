resource "random_password" "pynapple_password" {
  length  = 12
  special = true
  override_special = "+:()~."
}

resource "aws_secretsmanager_secret" "application_db_user_pass" {
  name        = "${var.env_name}/${var.app_name}/db_app_pw"
  description = "Database password for ${local.env_app_name}"
}

resource "aws_secretsmanager_secret_version" "application_db_user_pass" {
  secret_id     = aws_secretsmanager_secret.application_db_user_pass.id
  secret_string = random_password.pynapple_password.result
}


data "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = module.rdbms.db_instance_master_user_secret_arn
}
