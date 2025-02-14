from diagrams import Cluster, Diagram, Edge
from diagrams.aws.general import Client
from diagrams.k8s.compute import Deployment, Pod
from diagrams.k8s.network import Service
from diagrams.onprem.database import MySQL
from diagrams.onprem.inmemory import Redis
from diagrams.onprem.container import Docker
from diagrams.elastic.elasticsearch import Kibana, ElasticSearch
from diagrams.onprem.gitops import ArgoCD
from diagrams.onprem.monitoring import Grafana, Prometheus

with Diagram(name="fantastic-barnacle", show=False):
  user = Client("User")
  admin = Client("Admin")
  dockerhub = Client("Docker")

  with Cluster("Minikube"):
    redis = Redis("Redis")
    mysql = MySQL("MySql")

    argocd = ArgoCD("ArgoCd")
    grafana = Grafana("Grafana")
    prometheus = Prometheus("Prometheus")

    with Cluster("basic-backend"):
      bb_service = Service("Service")
      bb_deployment = Deployment("Deployment")
      bb_pods = [Pod("Pod1"), Pod("Pod2"), Pod("Pod3")]

    with Cluster("workload-handler"):
      wh_service = Service("Service")
      wh_deployment = Deployment("Deployment")
      wh_pods = [Pod("Pod1"), Pod("Pod2"), Pod("Pod3")]

    with Cluster("Elastic"):
      kibana = Kibana("Kibana")
      es = ElasticSearch("Elasticsearch")
  
  bb_service - bb_deployment - bb_pods
  wh_service - wh_deployment - wh_pods

  user >> Edge(color="red", label="Request") >> bb_service
  bb_pods >> Edge(color="red", label="Request Relayed via BullMQ") >> redis
  wh_pods >> Edge(color="red", label="Receives Request by Subscription") >> redis
  bb_service >> Edge(color="blue", label="Initial Response (skipped drawing deployments, pods)") >> user

  wh_pods >> Edge(color="darkblue", label="Response") >> redis
  bb_pods >> Edge(color="darkblue", label="Receives Response by Subscription") >> redis

  kibana - es

  bb_pods - Edge(color="darkgreen") - es
  wh_pods - Edge(color="darkgreen") - es

  admin - Edge(color="darkgreen") - kibana
  admin - Edge(color="purple", label="Invoke Deploy") - argocd
  argocd - Edge(color="purple") - bb_deployment
  argocd - Edge(color="purple") - wh_deployment