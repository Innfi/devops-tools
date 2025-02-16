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
  dockerhub = Client("Dockerhub")

  with Cluster("Minikube"):
    redis = Redis("Redis")
    argocd = ArgoCD("ArgoCd")

    bb_service = Service("basic-backend")
    wh_service = Service("workload-handler")

    with Cluster("Database"):
      mysql = MySQL("MySql")

    with Cluster("Elastic"):
      kibana = Kibana("Kibana")
      es = ElasticSearch("Elasticsearch")

    with Cluster("Cluster Metrics"):
      grafana = Grafana("Grafana")
      prometheus = Prometheus("Prometheus")


  user >> Edge(color="red", label="") >> bb_service
  bb_service >> Edge(color="red", label="") >> redis
  wh_service >> Edge(color="red", label="") >> redis


  wh_service >> Edge(color="magenta", label="") >> mysql

  kibana - es

  bb_service - Edge(color="darkgreen") - es
  wh_service - Edge(color="darkgreen") - es

  bb_service - Edge(color="darkgreen") - prometheus
  bb_service - Edge(color="darkgreen") - grafana

  wh_service - Edge(color="darkgreen") - prometheus
  wh_service - Edge(color="darkgreen") - grafana

  admin - Edge(color="darkgreen") - kibana
  admin - Edge(color="purple", label="") - argocd
  argocd - Edge(color="purple", label="") - dockerhub
  argocd - Edge(color="purple") - bb_service
  argocd - Edge(color="purple") - wh_service