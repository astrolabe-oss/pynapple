provider "aws" {
  region              = "us-east-1"
  allowed_account_ids = [var.aws_account_id]
}

provider "kubernetes" {
  for_each               = toset(var.enable_resources ? ["doit"] : [])
  alias                  = "dynamic"
  host                   = module.eks[0].cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks[0].cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth[0].cluster_auth.token
}

data "aws_eks_cluster_auth" "cluster_auth" {
  count = var.enable_resources ? 1 : 0
  name  = module.eks[0].cluster_name
}