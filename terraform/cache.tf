# Elasticache Subnet Group
resource "aws_elasticache_subnet_group" "main" {
  name       = "${var.project_name}-elasticache-subnet-group"
  subnet_ids = aws_subnet.private[*].id

  tags = merge(var.tags, {
    Name = "${var.project_name}-elasticache-subnet-group"
  })
}

# Elasticache Redis Cluster
resource "aws_elasticache_replication_group" "main" {
  replication_group_id       = "${var.project_name}-redis"
  description                = "Redis cluster for ${var.project_name}"
  engine                     = "redis"
  engine_version             = "7.0"
  node_type                  = var.elasticache_node_type
  number_cache_clusters      = var.elasticache_num_cache_nodes
  automatic_failover_enabled = var.elasticache_num_cache_nodes > 1
  port                       = 6379
  subnet_group_name          = aws_elasticache_subnet_group.main.name
  security_group_ids         = [aws_security_group.elasticache_sg.id]
  maintenance_window         = "sun:05:00-sun:06:00"
  snapshot_retention_limit   = 0
  snapshot_window            = "05:00-06:00"
  transit_encryption_enabled = true
  at_rest_encryption_enabled = true

  tags = merge(var.tags, {
    Name = "${var.project_name}-redis"
  })
}
