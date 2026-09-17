output "alb_dns_name" {
  description = "Public DNS name of the ALB."
  value       = aws_lb.main.dns_name
}

output "cluster_name" {
  description = "ECS cluster name."
  value       = aws_ecs_cluster.main.name
}

output "service_name" {
  description = "ECS service name."
  value       = aws_ecs_service.app.name
}

output "target_group_arn" {
  description = "ALB target group ARN."
  value       = aws_lb_target_group.app.arn
}
