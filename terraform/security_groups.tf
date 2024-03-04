resource "aws_security_group" "allow_ssh" {
  name        = "${local.env_name}${" dev ssh access"}"
  description = "Allow developer SSH access"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = local.ip_addresses_devs
  }
}

resource "aws_security_group" "pynapple_alb_to_asg" {
  name        = "${local.env_app_name}${" alb to asg"}"
  description = "Allow HTTP Traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [module.alb.security_group_id]
  }
}

resource "aws_security_group" "pynapple_instances_default" {
  name        = "${local.env_app_name}$ default"
  description = "Empty default security group for ${local.env_app_name} ec2 instances for referencing elsewhere"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_security_group" "pynapple_rds_access" {
  name        = "rds-sg"
  description = "Allow inbound traffic from EC2 instances to RDS"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port = 5432
    to_port   = 5432
    protocol  = "tcp"
    security_groups = [
      aws_security_group.pynapple_instances_default.id,
      module.eks.node_security_group_id
    ]
  }
}
