# Database Subnet Group
resource "aws_db_subnet_group" "main" {
  name       = "cloud-migration-db-subnet-group"
  subnet_ids = aws_subnet.private[*].id

  tags = {
    Name = "cloud-migration-db-subnet-group"
  }
}

# RDS Instance
resource "aws_db_instance" "main" {
  identifier            = "cloud-migration-db"
  engine                = var.db_engine
  engine_version        = var.db_engine_version
  instance_class        = var.db_instance_class
  allocated_storage     = var.db_allocated_storage
  name                  = var.db_name
  username              = var.db_username
  password              = var.db_password
  skip_final_snapshot   = true  # Set to false in production if you want a final snapshot
  publicly_accessible   = false
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.main.name
  multi_az              = true  # Set to true for production

  tags = {
    Name = "cloud-migration-db"
  }
}