resource "aws_security_group" "allow_ssh" {
  name        = "${local.env_name}${" dev ssh access"}"
  description = "Allow developer SSH access"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.developer_ip_cidrs
  }
}
