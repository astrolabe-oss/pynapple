locals {
  env_app_name   = "${var.env_name}-${var.app_name}"
  common_tags = merge(var.common_tags, {
    App         = var.app_name
  })
}
