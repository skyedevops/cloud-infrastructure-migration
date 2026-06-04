resource "aws_iam_role" "backup" {
  count = var.enable_aws_backup ? 1 : 0
  name  = "${var.project_name}-backup-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "backup.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "backup" {
  count      = var.enable_aws_backup ? 1 : 0
  role       = aws_iam_role.backup[0].name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
}

resource "aws_iam_role_policy_attachment" "backup_restore" {
  count      = var.enable_aws_backup ? 1 : 0
  role       = aws_iam_role.backup[0].name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForRestores"
}

resource "aws_backup_vault" "main" {
  count = var.enable_aws_backup ? 1 : 0
  name  = "${var.project_name}-vault"

  tags = var.tags
}

resource "aws_backup_plan" "main" {
  count = var.enable_aws_backup ? 1 : 0
  name  = "${var.project_name}-plan"

  rule {
    rule_name         = "nightly-30d"
    target_vault_name = aws_backup_vault.main[0].name
    schedule          = "cron(0 5 ? * * *)" # 05:00 UTC daily

    lifecycle {
      delete_after = 30
    }

    copy_action {
      destination_vault_arn = aws_backup_vault.main[0].arn
      lifecycle {
        delete_after = 30
      }
    }
  }

  tags = var.tags
}

resource "aws_backup_selection" "rds" {
  count        = var.enable_aws_backup ? 1 : 0
  plan_id      = aws_backup_plan.main[0].id
  name         = "${var.project_name}-rds"
  iam_role_arn = aws_iam_role.backup[0].arn

  resources = [
    aws_db_instance.main.arn
  ]
}
