variable "dockerhub_username" {
  description = "Username for Docker Hub"
  type        = string
}

variable "dockerhub_password" {
  description = "Password for Docker Hub"
  type        = string
}

variable "security_group_name" {
  description = "The name of the security group"
  type        = string
  default     = "terraform-Quarkus-instance3"
}
