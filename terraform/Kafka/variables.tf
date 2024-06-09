data "aws_secretsmanager_secret" "private_key" {
  name = var.key_pair_name
}

data "aws_secretsmanager_secret_version" "private_key_version" {
  secret_id = data.aws_secretsmanager_secret.private_key.id
}

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

variable "key_pair_name" {
  description = "The name of the key pair"
  type        = string
}
