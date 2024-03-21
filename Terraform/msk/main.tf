resource "aws_msk_cluster" "test_msk" {
  cluster_name = "test_msk"
  kafka_version = "3.2.0"
  number_of_broker_nodes = 3

  broker_node_group_info {
    instance_type = "kafka.t3.small"
    client_subnets = var.subnets    
    storage_info {
      ebs_storage_info {
        volume_size = 1000
      }
    }

    security_groups = var.security_group_ids
  }

  logging_info {
    broker_logs {
      cloudwatch_logs {
        enabled = true
        log_group = var.cloudwatch_log_group_name
      }
      firehose {
        enabled = true
        delivery_stream = var.kinesis_firehose_stream_name
      }
      s3 {
        enabled = true
        bucket = var.s3_bucket_id
      }
    }
  }
}