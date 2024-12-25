from diagrams import Cluster, Diagram
from diagrams.aws.compute import ECS
from diagrams.aws.database import ElastiCache, RDS
from diagrams.aws.network import ELB
from diagrams.aws.network import Route53

with Diagram("clustered web services", show=False):
  dns = Route53("dns")
  lb = ELB("loadbalancer")

  with Cluster("workload"):
    service_group = [
      ECS("web1"),
      ECS("web2"),
      ECS("web3")
    ]
  with Cluster("db cluster"):
    db_primary = RDS("userdb")
    db_primary - [RDS("userdb reader")]

  memcached = ElastiCache("memcached")

  dns >> lb >> service_group
  service_group >> db_primary
  service_group >> memcached
