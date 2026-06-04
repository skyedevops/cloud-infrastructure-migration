output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = aws_subnet.private[*].id
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.main.dns_name
}

output "alb_zone_id" {
  description = "Canonical hosted zone ID of the ALB (for Route53 alias records)"
  value       = aws_lb.main.zone_id
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = aws_lb.main.arn
}

output "target_group_arn" {
  description = "ARN of the web target group"
  value       = aws_lb_target_group.web_tg.arn
}

output "asg_name" {
  description = "Name of the Auto Scaling Group"
  value       = aws_autoscaling_group.web_asg.name
}

output "rds_endpoint" {
  description = "RDS endpoint address (null sensitive output may appear empty in some flows)"
  value       = aws_db_instance.main.address
}

output "rds_port" {
  description = "RDS port"
  value       = aws_db_instance.main.port
}

output "elasticache_endpoint" {
  description = "ElastiCache primary endpoint"
  value       = aws_elasticache_replication_group.main.primary_endpoint_address
}

output "s3_static_assets_bucket" {
  description = "S3 bucket hosting static assets"
  value       = var.enable_static_assets ? aws_s3_bucket.static_assets[0].bucket : null
}

output "cloudfront_domain" {
  description = "CloudFront distribution domain name"
  value       = var.enable_static_assets ? aws_cloudfront_distribution.static_assets[0].domain_name : null
}

output "sns_alerts_topic_arn" {
  description = "ARN of the SNS topic for CloudWatch alarm notifications"
  value       = var.alert_email != "" ? aws_sns_topic.alerts[0].arn : null
}

output "db_secret_arn" {
  description = "ARN of the Secrets Manager secret holding the DB credentials"
  value       = local.db_secret_arn
}

output "github_actions_role_arn" {
  description = "ARN of the IAM role assumed by GitHub Actions via OIDC"
  value       = aws_iam_role.github_deploy.arn
}

output "waf_web_acl_arn" {
  description = "ARN of the WAFv2 web ACL attached to the ALB"
  value       = var.enable_waf ? aws_wafv2_web_acl.alb[0].arn : null
}
