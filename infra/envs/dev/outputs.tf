output "alb_dns_name" {
  description = "Public ALB DNS name."
  value       = module.ecs.alb_dns_name
}

output "vpc_id" {
  description = "VPC ID."
  value       = module.network.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet IDs."
  value       = module.network.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnet IDs."
  value       = module.network.private_subnet_ids
}

output "ecs_cluster_name" {
  description = "ECS cluster name."
  value       = module.ecs.cluster_name
}

output "ecs_service_name" {
  description = "ECS service name."
  value       = module.ecs.service_name
}

output "rds_endpoint" {
  description = "Private RDS endpoint."
  value       = module.rds.endpoint
  sensitive   = true
}

output "rds_port" {
  description = "RDS port."
  value       = module.rds.port
}
