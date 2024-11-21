resource "aws_security_group" "alb_to_asg" {
  count       = var.deploy_app ? 1 : 0
  name        = "${local.env_app_name}${" alb to asg"}"
  description = "Allow HTTP Traffic"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = var.deploy_app ? [module.alb[0].security_group_id] : []
  }
}

resource "aws_security_group" "instances_default" {
  name        = "${local.env_app_name} default"
  description = "Empty default security group for ${local.env_app_name} ec2 instances for reference elsewhere"
  vpc_id      = var.vpc_id
}

resource "aws_security_group" "rds_access" {
  name        = "${local.env_app_name}-rds-sg"
  description = "Allow inbound traffic from EC2 instances to RDS"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.instances_default.id]
  }

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = var.ip_addresses_devs
  }

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.instances_default.id]
  }

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = var.ip_addresses_devs
  }

}
