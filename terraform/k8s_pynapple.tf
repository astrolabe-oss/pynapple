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
            name  = "PYNAPPLE_DATABASE_URI"
            value = "postgresql://pynapple@sandbox1-pynapple-db.chqoygiays09.us-east-1.rds.amazonaws.com:5432/pynapple"
          }
          env {
            name  = "FLASK_ENV"
            value = "development"
          }
        }
      }
    }
  }
}


#resource "kubernetes_service" "pynapple_lb" {
#  metadata { name = "${local.env_app_name}-lb" }
#  spec {
#    selector = { app = local.app_name }
#    port {
#      port        = 80
#      target_port = 80
#    }
#    type = "LoadBalancer"
#  }
#}
##
##resource "kubernetes_ingress_v1" "pynapple_ingress" {
##  metadata {
##    name        = "${local.app_name}-ingress"
##    namespace   = "default"
##    annotations = {
##      "kubernetes.io/ingress.class"                       = "alb"
##      "alb.ingress.kubernetes.io/scheme"                  = "internet-facing"
##      "alb.ingress.kubernetes.io/target-type"             = "ip"
##      "alb.ingress.kubernetes.io/listen-ports"            = '[{"HTTP": 80}, {"HTTPS": 443}]'
###      "alb.ingress.kubernetes.io/certificate-arn"         = "your_certificate_arn_here"
##      "alb.ingress.kubernetes.io/load-balancer-attributes"= "access_logs.s3.enabled=true,access_logs.s3.bucket=${aws_s3_bucket.pynapple_nlb_logs},access_logs.s3.prefix=${local.app_name}_k8s_service"
##      # Uncomment and replace the placeholders as necessary
##      # "alb.ingress.kubernetes.io/security-groups"       = "your_sg_id_here"
##      # "alb.ingress.kubernetes.io/subnets"               = "your_subnet_1_id_here,your_subnet_2_id_here"
##    }
##  }
##
##  spec {
##    rule {
##      http {
##        path {
##          path     = "/"
##          path_type = "Prefix"
##
##          backend {
##            service {
##              name = "pynapple-service"
##              port {
##                number = 80
##              }
##            }
##          }
##        }
##      }
##    }
##  }
##}
##
