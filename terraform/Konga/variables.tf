variable "security_group_name" {
  description = "The name of the security group"
  type        = string
  default     = "terraform-konga-instance5"
}

variable "addressKong" {
  description = "The Kong address"
  type        = string
  default     = "http://localhost:8001"
}
