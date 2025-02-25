locals {
  env_name = "sandbox1"
  app_name = "astrolabe"
  common_tags = {
    Terraform   = "true"
    Environment = local.env_name
    App         = local.app_name
  }
  pynapple2_coredns_host = "${module.pynapple2[0].k8s_service_name}.${module.pynapple2[0].k8s_service_namespace}.svc.cluster.local"
}
