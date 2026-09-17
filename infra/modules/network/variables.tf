variable "project_name" {
  description = "Name prefix for network resources."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets, one per AZ."
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets, one per AZ."
  type        = list(string)
}

variable "availability_zones" {
  description = "Availability zones for public and private subnet pairs."
  type        = list(string)
}

variable "tags" {
  description = "Common tags."
  type        = map(string)
  default     = {}
}
