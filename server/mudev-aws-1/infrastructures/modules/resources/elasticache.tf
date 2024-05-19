resource "aws_elasticache_subnet_group" "mudev-redis-subnet-group" {
  name       = "mudev-redis-subnet-group"
  subnet_ids = var.default_subnet_ids
  tags       = { Terraform = "true" }
}

resource "aws_elasticache_replication_group" "mudev-redis" {
  at_rest_encryption_enabled = true
  auto_minor_version_upgrade = true
  automatic_failover_enabled = false
  data_tiering_enabled       = false
  engine                     = "redis"
  engine_version             = "7.0"
  ip_discovery               = "ipv4"
  maintenance_window         = "thu:04:30-thu:05:30"
  multi_az_enabled           = false
  network_type               = "ipv4"
  node_type                  = "cache.t3.micro"
  num_cache_clusters         = 1
  parameter_group_name       = "default.redis7"
  port                       = 6379
  replicas_per_node_group    = 0
  replication_group_id       = "mudev-redis"
  description                = "mudev-redis"
  snapshot_retention_limit   = 1
  snapshot_window            = "13:51-14:51"
  subnet_group_name          = aws_elasticache_subnet_group.mudev-redis-subnet-group.name
  transit_encryption_enabled = true
  transit_encryption_mode    = "required"

  lifecycle {
    ignore_changes = [num_cache_clusters]
  }
  timeouts {}
  tags = { Terraform = "true" }
}
