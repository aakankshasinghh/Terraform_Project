aws_region   = "ap-south-1"
project_name = "devops-assessment-prod"
environment  = "prod"

vpc_cidr             = "10.20.0.0/16"
public_subnet_cidrs  = ["10.20.0.0/24", "10.20.1.0/24"]
private_subnet_cidrs = ["10.20.10.0/24", "10.20.11.0/24"]
availability_zones   = ["ap-south-1a", "ap-south-1b"]

container_image    = "nginx:latest"
container_port     = 80
ecs_task_cpu       = "256"
ecs_task_memory    = "512"
ecs_desired_count  = 2
log_retention_days = 30

db_engine                  = "postgres"
db_engine_version          = "16.3"
db_instance_class          = "db.t3.small"
db_allocated_storage       = 50
db_name                    = "appdb"
db_username                = "app_admin"
db_backup_retention_period = 14
db_deletion_protection     = true
db_multi_az                = true

# Assessment placeholder only. Use TF_VAR_db_password instead of a real secret.
db_password = "ASSESSMENT_ONLY_CHANGE_ME"
