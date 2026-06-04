variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "List of public subnet CIDR blocks (one per AZ)"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "List of private subnet CIDR blocks (one per AZ)"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to reach the ALB on HTTP/HTTPS"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "ssh_cidr_blocks" {
  description = "CIDR blocks allowed to SSH to EC2 instances (restrict in production)"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "instance_type" {
  description = "EC2 instance type for the web tier"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "EC2 Key Pair name for SSH access. Leave empty to skip."
  type        = string
  default     = ""
}

variable "asg_min_size" {
  description = "Minimum number of EC2 instances in the ASG"
  type        = number
  default     = 2
}

variable "asg_max_size" {
  description = "Maximum number of EC2 instances in the ASG"
  type        = number
  default     = 4
}

variable "asg_desired_capacity" {
  description = "Desired number of EC2 instances in the ASG"
  type        = number
  default     = 2
}

variable "db_engine" {
  description = "RDS database engine"
  type        = string
  default     = "mysql"
}

variable "db_engine_version" {
  description = "RDS database engine version"
  type        = string
  default     = "8.0"
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "RDS allocated storage in GiB"
  type        = number
  default     = 20
}

variable "db_name" {
  description = "Initial database name"
  type        = string
  default     = "migrationdb"
}

variable "db_username" {
  description = "Master DB username"
  type        = string
  default     = "admin"
}

variable "db_password" {
  description = "Master DB password. Use AWS Secrets Manager or TF_VAR_db_password env var in production."
  type        = string
  sensitive   = true
  default     = null
}

variable "db_multi_az" {
  description = "Enable Multi-AZ for RDS"
  type        = bool
  default     = true
}

variable "elasticache_node_type" {
  description = "ElastiCache node type"
  type        = string
  default     = "cache.t3.micro"
}

variable "elasticache_num_cache_nodes" {
  description = "Number of cache nodes (use 1 unless automatic_failover_enabled is true)"
  type        = number
  default     = 1
}

variable "enable_nat_gateway" {
  description = "Create a NAT Gateway for private subnet egress (incurs cost)"
  type        = bool
  default     = true
}

variable "static_assets_bucket_name" {
  description = "Globally-unique S3 bucket name for static assets. Leave empty to auto-generate."
  type        = string
  default     = ""
}

variable "domain_name" {
  description = "Public domain name (e.g. example.com). Used for ALB / CloudFront. Leave empty to skip HTTPS."
  type        = string
  default     = ""
}

variable "alert_email" {
  description = "Email address to receive CloudWatch alarm notifications. Leave empty to skip SNS topic."
  type        = string
  default     = ""
}

variable "project_name" {
  description = "Project name used for resource tagging"
  type        = string
  default     = "cloud-migration"
}

variable "environment" {
  description = "Deployment environment (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "enable_static_assets" {
  description = "Provision S3 + CloudFront for static assets"
  type        = bool
  default     = true
}

variable "db_password_secret_arn" {
  description = "ARN of the Secrets Manager secret holding the DB password. Leave empty to use var.db_password."
  type        = string
  default     = ""
}

variable "enable_instance_refresh" {
  description = "Enable ASG instance refresh for rolling updates"
  type        = bool
  default     = true
}

variable "enable_backups_bucket" {
  description = "Provision an S3 bucket for backups (DB exports, app dumps)"
  type        = bool
  default     = true
}

variable "enable_waf" {
  description = "Attach a WAFv2 web ACL to the ALB"
  type        = bool
  default     = true
}

variable "enable_route53" {
  description = "Create Route53 records pointing to the ALB and CloudFront distribution"
  type        = bool
  default     = false
}

variable "route53_zone_id" {
  description = "Route53 hosted zone ID for var.domain_name (required if enable_route53=true)"
  type        = string
  default     = ""
}

variable "enable_aws_backup" {
  description = "Create an AWS Backup plan that snapshots RDS nightly"
  type        = bool
  default     = true
}

variable "github_org" {
  description = "GitHub organization/user that owns the repo (used for OIDC trust)"
  type        = string
  default     = "skyedevops"
}

variable "github_repo" {
  description = "GitHub repository name (used for OIDC trust)"
  type        = string
  default     = "cloud-infrastructure-migration"
}

variable "tf_state_bucket" {
  description = "S3 bucket where Terraform state is stored (used by the deploy role policy)"
  type        = string
  default     = "my-tf-state"
}

variable "tf_locks_table" {
  description = "DynamoDB table used for Terraform state locking (used by the deploy role policy)"
  type        = string
  default     = "my-tf-locks"
}
