locals {
  env_name = "sandbox1"
  app_name = "astrolabe"
  common_tags = {
    Terraform   = "true"
    Environment = local.env_name
    App         = local.app_name
  }
}
