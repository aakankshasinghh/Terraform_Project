resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = merge(var.tags, {
    Name = "${var.project_name}-db-subnet-group"
  })
}

resource "aws_db_instance" "main" {
  identifier     = "${var.project_name}-db"
  engine         = var.db_engine
  engine_version = var.db_engine_version
  instance_class = var.db_instance_class

  allocated_storage   = var.db_allocated_storage
  storage_type        = "gp3"
  storage_encrypted   = true
  deletion_protection = var.db_deletion_protection

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password
  port     = var.db_port

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [var.rds_security_group_id]
  publicly_accessible    = false

  multi_az                = var.db_multi_az
  backup_retention_period = var.db_backup_retention_period
  skip_final_snapshot     = !var.db_deletion_protection

  final_snapshot_identifier = var.db_deletion_protection ? "${var.project_name}-final-snapshot" : null

  tags = merge(var.tags, {
    Name = "${var.project_name}-db"
  })
}
