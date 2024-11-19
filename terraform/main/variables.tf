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

variable "key_pair_name" {
  description = "AWS EC2 Key Pair to be used with EC2 Instances"
  type        = string
  default     = "astrolabe"
}

variable "developer_ip_cidrs" {
  description = "List of CIDRs for developer individual IP addresses"
  type        = list(string)
  default     = ["0.0.0.0/0"]  # Default allows access from anywhere
}

variable "aws_account_id" {
  description = "The AWS Account we want to restrict usage too"
  type        = string
  default     = "112795234683"
}