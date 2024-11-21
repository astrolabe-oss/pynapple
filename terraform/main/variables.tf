variable "deploy_infra" {
  description = "Deploy EKS, etc..."
  type        = bool
  default     = true
}

variable "deploy_app" {
  description = "Deploy app (LBs, ASGs, Pods Services, etc)"
  type        = bool
  default     = false
}

variable "key_pair_name" {
  description = "AWS EC2 Key Pair to be used with EC2 Instances"
  type        = string
  default     = "pynapple_key_pair"
}

variable "developer_ip_cidrs" {
  description = "List of CIDRs for developer individual IP addresses"
  type        = list(string)
  default     = ["0.0.0.0/0"]  # Default allows access from anywhere
}

variable "aws_account_id" {
  description = "The AWS Account we want to restrict usage too"
  type        = string
}

variable "aws_profile" {
  description = "The AWS Profile to use for configuring AWS provider"
  type        = string
  default     = "default"
}