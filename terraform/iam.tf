data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}

# IAM Role assumed by EC2 instances
resource "aws_iam_role" "ec2_role" {
  name = "${var.project_name}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = var.tags
}

# SSM (Session Manager) + CloudWatch Agent
resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "cw_agent" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# Read-only access to the static assets bucket for sync tasks
resource "aws_iam_role_policy" "s3_read_static" {
  count = var.enable_static_assets ? 1 : 0
  name  = "${var.project_name}-s3-read-static"
  role  = aws_iam_role.ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.static_assets[0].arn,
          "${aws_s3_bucket.static_assets[0].arn}/*"
        ]
      }
    ]
  })
}

# Optional: read DB password from Secrets Manager
resource "aws_iam_role_policy" "secrets_read" {
  count = var.db_password_secret_arn != "" ? 1 : 0
  name  = "${var.project_name}-secrets-read"
  role  = aws_iam_role.ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["secretsmanager:GetSecretValue"]
        Resource = [var.db_password_secret_arn]
      }
    ]
  })
}

resource "aws_iam_instance_profile" "ec2" {
  name = "${var.project_name}-ec2-profile"
  role = aws_iam_role.ec2_role.name

  tags = var.tags
}
