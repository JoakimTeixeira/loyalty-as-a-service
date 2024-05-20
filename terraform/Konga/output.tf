output "address" {
  value       = aws_instance.installKonga.public_dns
  description = "Connect to the KONGA at this endpoint"
}
