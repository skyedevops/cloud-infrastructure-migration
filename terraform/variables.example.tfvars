# Example variables.tfvars file
# Copy this to variables.tfvars and fill in your values

aws_region = "us-east-1"

# Optional: if you want to override defaults
# vpc_cidr = "10.0.0.0/16"
# public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
# private_subnet_cidrs = ["10.0.101.0/24", "10.0.102.0/24"]
# instance_type = "t3.micro"
# key_name = "your-key-pair-name"  # Leave empty if you don't want SSH access
# db_instance_class = "db.t3.micro"
# db_allocated_storage = 20
# db_engine = "mysql"
# db_engine_version = "8.0"
# db_name = "migrationdb"
# db_username = "admin"
# db_password = "your-secure-password"  # Note: storing passwords in tfvars is not recommended for production
# allowed_cidr_blocks = ["0.0.0.0/0"]  # Restrict this in production!