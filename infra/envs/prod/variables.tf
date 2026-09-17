variable "aws_region" {
  description = "AWS region."
  type        = string
  default     = "ap-south-1"
}

variable "project_name" {
  description = "Resource name prefix."
  type        = string
}

variable "environment" {
  description = "Environment name."
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR."
  type        = string
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDRs."
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDRs."
  type        = list(string)
}

variable "availability_zones" {
  description = "Availability zones."
  type        = list(string)
}

variable "container_image" {
  description = "ECS application image."
  type        = string
  default     = "nginx:latest"
}

variable "container_port" {
  description = "Application port."
  type        = number
  default     = 80
}

variable "ecs_task_cpu" {
  description = "Fargate task CPU units."
  type        = string
  default     = "256"
}

variable "ecs_task_memory" {
  description = "Fargate task memory in MiB."
  type        = string
  default     = "512"
}

variable "ecs_desired_count" {
  description = "Desired ECS task count."
  type        = number
  default     = 1
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days."
  type        = number
  default     = 14
}

variable "db_engine" {
  description = "RDS engine."
  type        = string
  default     = "postgres"

  validation {
    condition     = contains(["postgres", "mysql"], var.db_engine)
    error_message = "db_engine must be either postgres or mysql."
  }
}

variable "db_engine_version" {
  description = "RDS engine version."
  type        = string
  default     = "16.3"
}

variable "db_instance_class" {
  description = "RDS instance class."
  type        = string
}

variable "db_allocated_storage" {
  description = "RDS storage in GB."
  type        = number
  default     = 20
}

variable "db_name" {
  description = "Initial RDS database name."
  type        = string
  default     = "appdb"
}

variable "db_username" {
  description = "RDS master username."
  type        = string
  default     = "app_admin"
}

variable "db_password" {
  description = "RDS master password. Supply TF_VAR_db_password in real usage."
  type        = string
  sensitive   = true
}

variable "db_backup_retention_period" {
  description = "RDS automated backup retention in days."
  type        = number
}

variable "db_deletion_protection" {
  description = "Enable RDS deletion protection."
  type        = bool
}

variable "db_multi_az" {
  description = "Enable RDS Multi-AZ."
  type        = bool
}

variable "tags" {
  description = "Common resource tags."
  type        = map(string)
  default     = { ManagedBy = "terraform" }
}
