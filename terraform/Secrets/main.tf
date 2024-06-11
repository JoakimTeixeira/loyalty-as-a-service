resource "tls_private_key" "private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "key_pair" {
  key_name   = var.key_pair_name
  public_key = tls_private_key.private_key.public_key_openssh
}

resource "aws_secretsmanager_secret" "key_pair" {
  name                           = var.key_pair_name
  description                    = "Secret for key pair"
  recovery_window_in_days        = 0
  force_overwrite_replica_secret = true
}

resource "aws_secretsmanager_secret_version" "key_pair_version" {
  secret_id     = aws_secretsmanager_secret.key_pair.id
  secret_string = tls_private_key.private_key.private_key_pem
}
