resource "kubernetes_deployment" "pynapple_app" {
  metadata {
    name = "pynapple"
    labels = {
      app = local.app_name
    }
  }
  spec {
    replicas = 2
    selector {
      match_labels = {
        app = local.app_name
      }
    }
    template {
      metadata {
        labels = {
          app = local.app_name
        }
      }
      spec {
        container {
          image             = "517988372097.dkr.ecr.us-east-1.amazonaws.com/sandbox1-pynapple:latest"
          name              = local.app_name
          image_pull_policy = "Always"


          env {
            name = "PYNAPPLE_DATABASE_URI"
            value_from {
              secret_key_ref {
                name = "pynapple-env"
                key  = "PYNAPPLE_DATABASE_URI"
              }
            }
          }
          env {
            name  = "FLASK_ENV"
            value = "development"
          }
          env {
            name  = "PYNAPPLE_REDIS_HOST"
            value = module.cache.cluster_cache_nodes[0].address
          }
        }
      }
    }
  }
}


resource "kubernetes_service" "pynapple_lb" {
  metadata { name = "${local.env_app_name}-lb" }
  spec {
    selector = { app = local.app_name }
    port {
      port        = 80
      target_port = 80
    }
    type = "LoadBalancer"
    load_balancer_source_ranges = local.ip_addresses_devs
  }
}
