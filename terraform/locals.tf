locals {
  env_name       = "sandbox1"
  common_tags = {
    Terraform   = "true"
    Environment = local.env_name
  }
  ip_address_pk     = "73.70.155.200/32"
  ip_address_world  = "0.0.0.0/0"
  ip_addresses_devs = [local.ip_address_pk, local.ip_address_world]
}
