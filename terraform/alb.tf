module "alb" {
  source = "terraform-aws-modules/alb/aws"

  name               = local.env_app_name
  load_balancer_type = "application"
  vpc_id             = module.vpc.vpc_id
  subnets            = module.vpc.public_subnets

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
      cidr_ipv4   = module.vpc.vpc_cidr_block
    }
  }

  access_logs = {
    bucket = aws_s3_bucket.pynapple_nlb_logs.bucket
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
  tags = local.common_tags
}