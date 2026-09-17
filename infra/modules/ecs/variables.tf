variable "project_name" {
  description = "Name prefix for ECS/ALB resources."
  type        = string
}

variable "aws_region" {
  description = "AWS region."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for the ALB target group."
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet IDs for the ALB."
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for ECS tasks."
  type        = list(string)
}

variable "alb_security_group_id" {
  description = "ALB security group ID."
  type        = string
}

variable "ecs_security_group_id" {
  description = "ECS task security group ID."
  type        = string
}

variable "container_image" {
  description = "Container image."
  type        = string
  default     = "nginx:latest"
}

variable "container_port" {
  description = "Application container port."
  type        = number
  default     = 80
}

variable "ecs_task_cpu" {
  description = "Fargate CPU units."
  type        = string
  default     = "256"
}

variable "ecs_task_memory" {
  description = "Fargate memory in MiB."
  type        = string
  default     = "512"
}

variable "ecs_desired_count" {
  description = "Desired ECS task count."
  type        = number
  default     = 1
}

variable "log_retention_days" {
  description = "CloudWatch log retention."
  type        = number
  default     = 14
}

variable "tags" {
  description = "Common tags."
  type        = map(string)
  default     = {}
}
