resource "aws_secretsmanager_secret" "db" {
  count                   = var.db_password_secret_arn == "" ? 1 : 0
  name                    = "${var.project_name}/db/master"
  description             = "Master credentials for ${var.project_name} RDS instance"
  recovery_window_in_days = var.environment == "prod" ? 30 : 7

  tags = var.tags
}

resource "aws_secretsmanager_secret_version" "db" {
  count = var.db_password_secret_arn == "" ? 1 : 0

  secret_id = aws_secretsmanager_secret.db[0].id
  secret_string = jsonencode({
    username = var.db_username
    password = var.db_password
    host     = aws_db_instance.main.address
    port     = aws_db_instance.main.port
    dbname   = var.db_name
    engine   = var.db_engine
  })
}

# If user provided an external secret, point outputs at it.
locals {
  db_secret_arn = var.db_password_secret_arn != "" ? var.db_password_secret_arn : (
    var.db_password_secret_arn == "" && length(aws_secretsmanager_secret.db) > 0 ? aws_secretsmanager_secret.db[0].arn : null
  )
}
