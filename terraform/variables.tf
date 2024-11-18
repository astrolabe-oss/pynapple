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