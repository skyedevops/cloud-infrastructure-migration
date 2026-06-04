# Elasticache Subnet Group
resource "aws_elasticache_subnet_group" "main" {
  name       = "cloud-migration-elasticache-subnet-group"
  subnet_ids = aws_subnet.private[*].id

  tags = {
    Name = "cloud-migration-elasticache-subnet-group"
  }
}

# Elasticache Redis Cluster
resource "aws_elasticache_replication_group" "main" {
  replication_group_id          = "cloud-migration-redis"
  description                   = "Redis cluster for cloud migration demo"
  engine                        = "redis"
  node_type                     = "cache.t3.micro"
  number_cache_clusters         = 1
  automatic_failover_enabled    = false  # Set to true for production with multi-node
  port                          = 6379
  subnet_group_name             = aws_elasticache_subnet_group.main.name
  security_group_ids            = [aws_security_group.elasticache_sg.id]
  maintenance_window            = "sunny:05:00-sunny:06:00"
  snapshot_retention_limit      = 0  # Set to a number >0 for production to retain snapshots
  snapshot_window               = "05:00-06:00"

  tags = {
    Name = "cloud-migration-redis"
  }
}