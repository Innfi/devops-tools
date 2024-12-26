from diagrams import Cluster, Diagram
from diagrams.aws.compute import ECS, EKS, EC2
from diagrams.aws.database import ElastiCache, RDS
from diagrams.aws.network import ELB, Route53, VPC, PublicSubnet, PrivateSubnet

with Diagram("clustered web services", show=False):
  dns = Route53("dns")
  lb = ELB("loadbalancer")

  with Cluster("workload"):
    service_group = [
      EC2("web1"),
      EC2("web2"),
      EC2("web3")
    ]

  eks = EKS("eks cluster")

  with Cluster("db cluster"):
    db_primary = RDS("userdb")
    db_primary - [RDS("userdb reader")]

  with Cluster("network"):
    main_vpc = VPC("main")
    subnet_pub = [PublicSubnet("pub_a"), PublicSubnet("pub_b")]

    main_vpc >> subnet_pub

  dns >> lb >> main_vpc

  dns >> lb >> service_group
  service_group >> db_primary
  dns >> lb >> eks

