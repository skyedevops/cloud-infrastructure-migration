terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  # The region can be set via AWS_DEFAULT_REGION environment variable
  # or via a shared credentials file.
  region = var.aws_region
}

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
  description = "List of public subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "List of private subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
}

# VPC Resource
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "cloud-migration-vpc"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "cloud-migration-igw"
  }
}

# Public Subnets
resource "aws_subnet" "public" {
  for_each = toset(var.public_subnet_cidrs)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value
  availability_zone       = data.aws_availability_zones.available.names[element(length(var.public_subnet_cidrs) > 0 ? index(var.public_subnet_cidrs, each.value) : 0, length(var.private_subnet_cidrs) > 0 ? index(var.private_subnet_cidrs, each.value) : 0)]
  map_public_ip_on_launch = true

  tags = {
    Name = "cloud-migration-public-subnet-${each.key}"
  }
}

# Private Subnets
resource "aws_subnet" "private" {
  for_each = toset(var.private_subnet_cidrs)

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value
  availability_zone = data.aws_availability_zones.available.names[element(length(var.public_subnet_cidrs) > 0 ? index(var.public_subnet_cidrs, each.value) : 0, length(var.private_subnet_cidrs) > 0 ? index(var.private_subnet_cidrs, each.value) : 0)]

  tags = {
    Name = "cloud-migration-private-subnet-${each.key}"
  }
}

# Route Table for Public Subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "cloud-migration-public-rt"
  }
}

# Associate Public Subnets with Route Table
resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

# Elastic IP for NAT Gateway (if needed for private subnets internet access)
# Note: For a simple migration, we might not need NAT if private subnets don't require internet access.
# We'll skip NAT for now to keep it simple and cost-effective.

# Outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = aws_subnet.private[*].id
}

# Data source for availability zones
data "aws_availability_zones" "available" {
  state = "available"
}