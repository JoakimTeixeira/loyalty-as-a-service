output "address" {
  value       = aws_db_instance.rds_db[*].address
  description = "Connect to the databases at these endpoints"
}

output "port" {
  value       = aws_db_instance.rds_db[*].port
  description = "The ports the databases are listening on"
}
