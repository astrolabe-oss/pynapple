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
variable "common_env_vars" {
  description = "Environment variables for all app runtimes"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "k8s_env_vars" {
  description = "Environment variables for the k8s containers"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "ec2_env_vars" {
  description = "Environment variables for the ec2 vms"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "cache_engine" {
  description = "Engine of the cache to create (redis or memcached)"
  type        = string
}

variable "database_engine" {
  description = "Engine of the database to create (postgres or mysql)"
  type        = string
}

variable "app_db_name" {
  description = "Database name for the application to use (schema, etc)"
  type        = string
}

variable "enable_resources" {
  description = "Enable or disable all EC2, RDS, cache instances, and pods."
  type        = bool
  default     = true
}

variable "instance_count" {
  description = "Default instance count for all EC2, RDS, and pods."
  type        = number
  default     = 1
}
