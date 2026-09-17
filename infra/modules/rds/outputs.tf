output "endpoint" {
  description = "Private RDS endpoint."
  value       = aws_db_instance.main.endpoint
  sensitive   = true
}

output "port" {
  description = "RDS port."
  value       = aws_db_instance.main.port
}

output "instance_identifier" {
  description = "RDS instance identifier."
  value       = aws_db_instance.main.identifier
}
