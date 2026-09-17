locals {
  db_port = var.db_engine == "postgres" ? 5432 : 3306

  tags = merge(var.tags, {
    Environment = var.environment
    Project     = var.project_name
  })
}

module "network" {
  source = "../../modules/network"

  project_name         = var.project_name
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones
  tags                 = local.tags
}

resource "aws_security_group" "alb" {
  name_prefix = "${var.project_name}-alb-"
  description = "Allow HTTP from the internet to the ALB"
  vpc_id      = module.network.vpc_id

  ingress {
    description = "HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.tags, { Name = "${var.project_name}-alb-sg" })
}

resource "aws_security_group" "ecs" {
  name_prefix = "${var.project_name}-ecs-"
  description = "Allow application traffic from the ALB only"
  vpc_id      = module.network.vpc_id

  ingress {
    description     = "Application traffic from ALB"
    from_port       = var.container_port
    to_port         = var.container_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.tags, { Name = "${var.project_name}-ecs-sg" })
}

resource "aws_security_group" "rds" {
  name_prefix = "${var.project_name}-rds-"
  description = "Allow database traffic from ECS tasks only"
  vpc_id      = module.network.vpc_id

  ingress {
    description     = "Database traffic from ECS"
    from_port       = local.db_port
    to_port         = local.db_port
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs.id]
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.tags, { Name = "${var.project_name}-rds-sg" })
}

module "ecs" {
  source = "../../modules/ecs"

  project_name          = var.project_name
  aws_region            = var.aws_region
  vpc_id                = module.network.vpc_id
  public_subnet_ids     = module.network.public_subnet_ids
  private_subnet_ids    = module.network.private_subnet_ids
  alb_security_group_id = aws_security_group.alb.id
  ecs_security_group_id = aws_security_group.ecs.id
  container_image       = var.container_image
  container_port        = var.container_port
  ecs_task_cpu          = var.ecs_task_cpu
  ecs_task_memory       = var.ecs_task_memory
  ecs_desired_count     = var.ecs_desired_count
  log_retention_days    = var.log_retention_days
  tags                  = local.tags
}

module "rds" {
  source = "../../modules/rds"

  project_name             = var.project_name
  private_subnet_ids       = module.network.private_subnet_ids
  rds_security_group_id    = aws_security_group.rds.id
  db_engine                = var.db_engine
  db_engine_version        = var.db_engine_version
  db_instance_class        = var.db_instance_class
  db_allocated_storage     = var.db_allocated_storage
  db_name                  = var.db_name
  db_username              = var.db_username
  db_password              = var.db_password
  db_port                  = local.db_port
  db_backup_retention_period = var.db_backup_retention_period
  db_deletion_protection   = var.db_deletion_protection
  db_multi_az              = var.db_multi_az
  tags                     = local.tags
}
