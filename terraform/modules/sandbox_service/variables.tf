variable "env_name" {
  description = "Environment name."
  type        = string
}

variable "app_name" {
  description = "Application name."
  type        = string
}

variable "common_tags" {
  description = "Common tags for resources."
  type        = map(string)
  default     = {}
}

variable "key_pair_name" {
  description = "The EC2 SSH key pair name to use for EC2 instances."
  type        = string
}

# Networking
variable "vpc_id" {
  description = "The ID of the VPC where the ALB is deployed."
  type        = string
}

variable "ip_addresses_devs" {
  description = "List of developer IP addresses."
  type        = list(string)
}

variable "public_subnets" {
  description = "List of IDs of public subnets for the ALB."
  type        = list(string)
}

variable "private_subnets" {
  description = "List of IDs of private subnets for ElastiCache."
  type        = list(string)
}

variable "database_subnets" {
  description = "List of IDs of database subnets for RDS."
  type        = list(string)
}

variable "vpc_cidr_block" {
  description = "The CIDR block of the VPC."
  type        = string
}

variable "security_group_ids" {
  description = "List of security group IDs to associate with EC2 instances."
  type        = list(string)
}

# components
variable "ec2_user_data" {
  description = "User Data script (Do NOT pre base64encode it!)"
  type        = string
  default     = <<-EOF
    #!/bin/bash
    ### SETUP SSM SSH ###
    sudo systemctl start amazon-ssm-agent
  EOF
}

variable "create_redis" {
  description = "Whether to create the Redis ElastiCache"
  type        = bool
  default     = false
}

variable "app_db_name" {
  description = "Database name for the application to use (schema, etc)"
  type        = string
}

variable "app_db_pw_secret_arn" {
  description = "AWS Secrets Manager ARN for the application db secret"
  type        = string
}