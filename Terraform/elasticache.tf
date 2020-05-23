resource "aws_elasticache_cluster" "test-redis" {
    cluster_id = "test-redis" 
    engine = "redis" 
    node_type = "cache.m2.small" 
    num_cache_nodes = 1 
    parameter_group_name = "default.redis3.2" 
    port = 6379
}
