locals {
  env_name       = "sandbox1"
  app_name       = "pynapple"
  env_app_name   = "${local.env_name}-${local.app_name}"
  app_name_under = replace(local.app_name, "-", "_")
  common_tags = {
    Terraform   = "true"
    Environment = "sandbox1"
    App         = local.app_name
  }
  ip_address_pk     = "73.70.155.200/32"
  ip_address_world  = "0.0.0.0/0"
  ip_addresses_devs = [local.ip_address_pk, local.ip_address_world]
}
