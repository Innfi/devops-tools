from diagrams import Cluster, Diagram
from diagrams.k8s.network import Ingress, Service
from diagrams.k8s.compute import Pod, Deployment
from diagrams.k8s.podconfig import ConfigMap
from diagrams.aws.compute import ECS, EKS, EC2
from diagrams.aws.database import RDS
from diagrams.aws.network import ELB, Route53
from diagrams.aws.integration import SQS

with Diagram("eks_test", show=False):
  with Cluster("AWS"):
    route53 = Route53("dns")
    elb = ELB("elb")
    rds = RDS("rds")
    sqs = SQS("queue")

    with Cluster("eks"):
      ingress = Ingress("ingress")
      configmap = ConfigMap("common")

      with Cluster("compound1"):
        service = Service("compound 1 service")
        deployment = Deployment("compound 1 deployment")
        pods = [
          Pod("compound 1 pod1"), 
          Pod("compound 1 pod2"), 
          Pod("compound 1 pod3")
        ]
        service >> deployment >> pods
        pods - rds

      ingress >> service
      deployment - configmap 

      with Cluster("compound2"):
        service2 = Service("compound 2 service")
        deployment2 = Deployment("compound 2 deployment")
        pods2 = [
          Pod("compound 2 pod1"), 
        ]
        service2 >> deployment2 >> pods2
        pods2 - rds

      ingress >> service2
      deployment2 - configmap 

    route53 >> elb >> ingress
    pods - sqs - pods2