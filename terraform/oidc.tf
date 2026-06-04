data "tls_certificate" "github" {
  url = "https://token.actions.githubusercontent.com"
}

resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.github.certificates[0].sha1_fingerprint]

  tags = var.tags
}

data "aws_iam_policy_document" "github_deploy" {
  statement {
    sid    = "AllowGitHubOIDC"
    effect = "Allow"

    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${var.github_org}/${var.github_repo}:*"]
    }
  }
}

resource "aws_iam_role" "github_deploy" {
  name               = "${var.project_name}-github-deploy"
  assume_role_policy = data.aws_iam_policy_document.github_deploy.json
  tags               = var.tags
}

data "aws_iam_policy_document" "github_deploy_inline" {
  statement {
    sid    = "AllowS3StateAndLock"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:ListBucket"
    ]
    resources = [
      "arn:${data.aws_partition.current.partition}:s3:::${var.tf_state_bucket}",
      "arn:${data.aws_partition.current.partition}:s3:::${var.tf_state_bucket}/*"
    ]
  }

  statement {
    sid       = "AllowDynamoDBLock"
    effect    = "Allow"
    actions   = ["dynamodb:GetItem", "dynamodb:PutItem", "dynamodb:DeleteItem"]
    resources = ["arn:${data.aws_partition.current.partition}:dynamodb:*:*:table/${var.tf_locks_table}"]
  }

  statement {
    sid       = "AllowInfrastructureManagement"
    effect    = "Allow"
    actions   = ["*"]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "github_deploy_inline" {
  name   = "${var.project_name}-github-deploy-inline"
  role   = aws_iam_role.github_deploy.id
  policy = data.aws_iam_policy_document.github_deploy_inline.json
}
