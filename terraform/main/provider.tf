provider "aws" {
  region              = "us-east-1"
  allowed_account_ids = [var.aws_account_id]
  profile             = var.aws_profile
}

provider "kubernetes" {
#   for_each               = toset(var.deploy_infra ? ["this"] : [])
#   alias                  = "dynamic"
  host                   = var.deploy_infra ? module.eks[0].cluster_endpoint : null
  cluster_ca_certificate = var.deploy_infra ? base64decode(module.eks[0].cluster_certificate_authority_data) : null
  token                  = var.deploy_infra ? data.aws_eks_cluster_auth.cluster_auth[0].token : null
}

data "aws_eks_cluster_auth" "cluster_auth" {
  count = var.deploy_infra ? 1 : 0
  name  = module.eks[0].cluster_name
}