provider "aws" {
  region              = "us-east-1"
  allowed_account_ids = ["517988372097"] # Chris Robertson AWS Account
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.cluster_auth.token
}

data "aws_eks_cluster_auth" "cluster_auth" {
  name = module.eks.cluster_name
}