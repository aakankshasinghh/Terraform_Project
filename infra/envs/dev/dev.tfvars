aws_region   = "ap-south-1"
project_name = "devops-assessment-dev"
environment  = "dev"

vpc_cidr             = "10.10.0.0/16"
public_subnet_cidrs  = ["10.10.0.0/24", "10.10.1.0/24"]
private_subnet_cidrs = ["10.10.10.0/24", "10.10.11.0/24"]
availability_zones   = ["ap-south-1a", "ap-south-1b"]

container_image   = "nginx:latest"
container_port    = 80
ecs_task_cpu      = "256"
ecs_task_memory   = "512"
ecs_desired_count = 1
log_retention_days = 7

db_engine                   = "postgres"
db_engine_version           = "16.3"
db_instance_class           = "db.t3.micro"
db_allocated_storage        = 20
db_name                     = "appdb"
db_username                 = "app_admin"
db_backup_retention_period  = 3
db_deletion_protection      = false
db_multi_az                 = false

# Assessment placeholder only. Use TF_VAR_db_password instead of a real secret.
db_password = "ASSESSMENT_ONLY_CHANGE_ME"
