variable "db_username" {
  description = "The username for the database"
  type        = string
  sensitive   = true
  default     = "teste"
}

variable "db_password" {
  description = "The password for the database"
  type        = string
  sensitive   = true
  default     = "testeteste"
}

variable "db_name" {
  description = "The name to use for the database"
  type        = string
  default     = "quarkus_test_all_operations"
}

variable "security_group_name" {
  description = "The name of the security group"
  type        = string
  default     = "terraform-rds-database"
}
