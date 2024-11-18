module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = "${local.env_name}-eks"
  cluster_version = "1.31"
  subnet_ids      = module.vpc.public_subnets
  vpc_id          = module.vpc.vpc_id

  eks_managed_node_group_defaults = {
    instance_types = ["t4g.small"]
  }

  eks_managed_node_groups = var.enable_resources ? {
    "${local.env_name}_eks_ng1_arm" = {
      max_capacity  = 2
      min_capacity  = 1
      capacity_type = "SPOT"
      instance_type = "t4g.small"
      ami_type      = "AL2_ARM_64"
      key_name      = aws_key_pair.infra_2024_1_30_1.key_name
    }
  } : {}

  enable_cluster_creator_admin_permissions = true

  cluster_endpoint_public_access       = true
  cluster_endpoint_public_access_cidrs = local.ip_addresses_devs

  tags = local.common_tags
}

# resource "null_resource" "install_metrics_server" {
#   triggers = {
#     always_run = false # timestamp()
#   }
#
#   provisioner "local-exec" {
#     command = "kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml"
#   }
# }