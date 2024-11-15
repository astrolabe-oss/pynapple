locals {
  k8s_combined_env_vars = concat(var.common_env_vars, var.k8s_env_vars)
}

resource "kubernetes_deployment" "this" {
  depends_on = [
    kubernetes_secret.db_secret,
    module.asg # this is because during first apply, we need the ASG to come up to run db init scripts...
  ]
  metadata {
    name = var.app_name
    labels = {
      app = var.app_name
    }
  }
  spec {
    replicas = var.enable_resources ? var.instance_count * 2 : 0
    selector {
      match_labels = {
        app = var.app_name
      }
    }
    template {
      metadata {
        labels = {
          app = var.app_name
        }
      }
      spec {
        container {
          image             = "${aws_ecr_repository.this.repository_url}:latest"
          name              = var.app_name
          image_pull_policy = "Always"
          env {
            name  = "SANDBOX_APP_NAME"
            value = var.app_name
          }
          env {
            name = "SANDBOX_DATABASE_URI"
            value_from {
              secret_key_ref {
                name = "${var.app_name}-env"
                key  = "SANDBOX_DATABASE_URI"
              }
            }
          }
          dynamic "env" {
            for_each = var.enable_resources && var.cache_engine == "redis" ? [1] : []
            content {
              name  = "SANDBOX_REDIS_HOST"
              value = var.enable_resources ? module.cache[0].cluster_cache_nodes.address : ""
            }
          }

          dynamic "env" {
            for_each = var.enable_resources && var.cache_engine == "memcached" ? [1] : []
            content {
              name  = "SANDBOX_MEMCACHED_HOST"
              value = var.enable_resources ? "${module.cache[0].cluster_cache_nodes.address}:11211" : ""
            }
          }
          dynamic "env" {
            for_each = local.k8s_combined_env_vars
            content {
              name  = env.value.name
              value = env.value.value
            }
          }
        }
      }
    }
  }
}


resource "kubernetes_service" "pynapple_lb" {
  count = var.enable_resources ? 1 : 0

  metadata { name = "${local.env_app_name}-lb" }
  spec {
    selector = { app = var.app_name }
    port {
      port        = 80
      target_port = 80
    }
    type                        = "LoadBalancer"
    load_balancer_source_ranges = var.ip_addresses_devs
  }
}

resource "kubernetes_secret" "db_secret" {
  metadata {
    name = "${var.app_name}-env"
  }

  data = {
    SANDBOX_DATABASE_URI = local.database_conn_str
  }
}