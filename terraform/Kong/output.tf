output "address" {
  value       = aws_instance.installKong.public_dns
  description = "Connect to the KONG at this endpoint"
}
