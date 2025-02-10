from diagrams import Cluster, Diagram, Edge
from diagrams.aws.compute import EKS, EC2, Lambda
from diagrams.aws.database import AuroraInstance, DDB
from diagrams.aws.network import Route53
from diagrams.aws.integration import SQS, SNS
from diagrams.aws.general import Users
from diagrams.elastic.elasticsearch import Kibana, ElasticSearch

with Diagram("compound", show=False):
  users = Users("Users")

  with Cluster("AWS"):
    workload_handler = EC2("Workload Handler")

    route53 = Route53("DNS")
    sns = SNS("SNS")
    sqs = SQS("SQS")
    lambda_func = Lambda("Lambda")
    functionbeat = Lambda("Lambda-Functionbeat")
    dynamo = DDB("Dynamo")
    aurora_primary = AuroraInstance("Aurora Primary")
    aurora_secondary = AuroraInstance("Aurora Secondary")

  with Cluster("Elastic"):
    es = ElasticSearch("Elasticsearch")
    kibana = Kibana("Kibana")


  users >> Edge(color="red", label="DNS Request") >> route53
  route53 >> Edge(color="red", label="DNS Response") >> users

  users >> Edge(color="purple", label="Web Request") >> workload_handler
  workload_handler >> Edge(color="purple", label="Database Operation") >> aurora_primary
  aurora_primary - Edge(color="orange") - aurora_secondary

  workload_handler >> Edge(color="darkblue", label="Trigger Notification") >> sns 
  sns >> Edge(color="darkblue", label="Propagation") >> sqs >> Edge(color="darkblue", label="Propagation") >> lambda_func
  lambda_func >> Edge(color="darkblue") >> dynamo

  sns >> Edge(color="blue", label="Propagation") >> sqs >> Edge(color="blue", label="Propagation") >> functionbeat
  functionbeat >> Edge(color="blue", label="Propagation") >> es

  kibana - Edge(color="orange") - es
