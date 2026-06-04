# Database Subnet Group
resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = aws_subnet.private[*].id

  tags = merge(var.tags, {
    Name = "${var.project_name}-db-subnet-group"
  })
}

# RDS Parameter Group
resource "aws_db_parameter_group" "main" {
  name        = "${var.project_name}-db-params"
  family      = "${var.db_engine}${split(".", var.db_engine_version)[0]}"
  description = "Parameter group for ${var.project_name}"

  parameter {
    name  = "slow_query_log"
    value = "1"
  }

  parameter {
    name  = "long_query_time"
    value = "2"
  }

  tags = var.tags
}

# RDS Instance
resource "aws_db_instance" "main" {
  identifier                      = "${var.project_name}-db"
  engine                          = var.db_engine
  engine_version                  = var.db_engine_version
  instance_class                  = var.db_instance_class
  allocated_storage               = var.db_allocated_storage
  max_allocated_storage           = var.db_allocated_storage * 4
  storage_type                    = "gp3"
  storage_encrypted               = true
  name                            = var.db_name
  username                        = var.db_username
  password                        = var.db_password
  skip_final_snapshot             = false
  final_snapshot_identifier       = "${var.project_name}-db-final"
  deletion_protection             = var.environment == "prod" ? true : false
  publicly_accessible             = false
  multi_az                        = var.db_multi_az
  backup_retention_period         = 7
  backup_window                   = "07:00-09:00"
  maintenance_window              = "Sun:09:30-Sun:10:30"
  enabled_cloudwatch_logs_exports = ["error", "general", "slowquery"]
  vpc_security_group_ids          = [aws_security_group.rds_sg.id]
  db_subnet_group_name            = aws_db_subnet_group.main.name
  parameter_group_name            = aws_db_parameter_group.main.name

  tags = merge(var.tags, {
    Name = "${var.project_name}-db"
  })
}
