variable "project_name" {
  description = "Name prefix for RDS resources."
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for the DB subnet group."
  type        = list(string)
}

variable "rds_security_group_id" {
  description = "RDS security group ID."
  type        = string
}

variable "db_engine" {
  description = "Database engine."
  type        = string

  validation {
    condition     = contains(["postgres", "mysql"], var.db_engine)
    error_message = "db_engine must be either postgres or mysql."
  }
}

variable "db_engine_version" {
  description = "RDS engine version."
  type        = string
}

variable "db_instance_class" {
  description = "RDS instance class."
  type        = string
}

variable "db_allocated_storage" {
  description = "RDS storage in GB."
  type        = number
}

variable "db_name" {
  description = "Initial database name."
  type        = string
}

variable "db_username" {
  description = "RDS master username."
  type        = string
}

variable "db_password" {
  description = "RDS master password."
  type        = string
  sensitive   = true
}

variable "db_port" {
  description = "Database port."
  type        = number
}

variable "db_backup_retention_period" {
  description = "Automated backup retention in days."
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
  description = "Common tags."
  type        = map(string)
  default     = {}
}
