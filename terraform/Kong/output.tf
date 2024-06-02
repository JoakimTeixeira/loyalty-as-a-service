output "address" {
  value       = aws_instance.installKongKongaCamunda.public_dns
  description = "Connect to the KONG, KONGA and CAMUNDA at this endpoint"
}
