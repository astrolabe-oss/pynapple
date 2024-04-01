resource "kubernetes_deployment" "this" {
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
    type = "LoadBalancer"
    load_balancer_source_ranges = var.ip_addresses_devs
  }
}
