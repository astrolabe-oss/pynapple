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
    replicas = 2
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
            for_each = var.cache_engine == "redis" ? [1] : []
            content {
              name  = "SANDBOX_REDIS_HOST"
              value = module.cache.cluster_cache_nodes[0].address
            }
          }
          dynamic "env" {
            for_each = var.cache_engine == "memcached" ? [1] : []
            content {
              name  = "SANDBOX_MEMCACHED_HOST"
              value = "${module.cache.cluster_cache_nodes[0].address}:11211"
            }
          }
          dynamic "env" {
            for_each = var.container_env_vars
            content {
              name  = env.value.name
              value = env.value.value

              dynamic "value_from" {
                for_each = env.value.valueFrom != null ? [env.value.valueFrom] : []
                content {
                  dynamic "secret_key_ref" {
                    for_each = env.value.valueFrom.secret_key_ref != null ? [env.value.valueFrom.secret_key_ref] : []
                    content {
                      name = secret_key_ref.value.name
                      key  = secret_key_ref.value.key
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}


resource "kubernetes_service" "pynapple_lb" {
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