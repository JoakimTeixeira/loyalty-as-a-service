variable "nBroker" {
  description = "Number of Kafka brokers in the cluster"
  type        = number
  default     = 1
}

variable "security_group_name" {
  description = "The name of the security group"
  type        = string
  default     = "terraform-example-instance5"
}
