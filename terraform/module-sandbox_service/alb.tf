module "alb" {
  source = "terraform-aws-modules/alb/aws"
  count                   = var.deploy_app ? 1 : 0

  name                       = local.env_app_name
  load_balancer_type         = "application"
  vpc_id                     = var.vpc_id
  subnets                    = var.public_subnets
  enable_deletion_protection = false

  # Security Group
  security_group_ingress_rules = {
    all_http = {
      from_port   = 80
      to_port     = 80
      ip_protocol = "tcp"
      description = "HTTP web traffic"
      cidr_ipv4   = "0.0.0.0/0"
    }
    all_https = {
      from_port   = 443
      to_port     = 443
      ip_protocol = "tcp"
      description = "HTTPS web traffic"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }
  security_group_egress_rules = {
    all = {
      ip_protocol = "-1"
      cidr_ipv4   = var.vpc_cidr_block
    }
  }

  target_groups = {
    asg = {
      name_prefix       = "http"
      backend_protocol  = "HTTP"
      backend_port      = 80
      target_type       = "instance"
      create_attachment = "false"
    },
  }

  listeners = [
    {
      port     = 80
      protocol = "HTTP"
      forward = {
        target_group_key = "asg"
      }
    }
  ]
  tags = var.common_tags
}