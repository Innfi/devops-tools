from diagrams import Cluster, Diagram
from diagrams.k8s.network import Ingress, Service
from diagrams.k8s.compute import Pod, Deployment
from diagrams.k8s.podconfig import ConfigMap

with Diagram("k8s", show=False):
  with Cluster("Minikube"):
    ingress = Ingress("nginx ingress")
    service = Service("service")
    deployment = Deployment("workload")
    configmap = ConfigMap("configurations")

    service >> configmap
    deployment >> configmap
    ingress - service - deployment
