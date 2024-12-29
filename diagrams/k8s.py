from diagrams import Cluster, Diagram
from diagrams.k8s.network import Ingress, Service
from diagrams.k8s.compute import Pod, Deployment
from diagrams.k8s.podconfig import ConfigMap

with Diagram("k8s", show=False):
  with Cluster("Minikube"):
    ingress = Ingress("nginx ingress")
    configmap = ConfigMap("configurations_common")

    with Cluster("compound1"):
      service = Service("compound 1 service")
      deployment = Deployment("compound 1 deployment")
      pods = [
        Pod("compound 1 pod1"), 
        Pod("compound 1 pod2"), 
        Pod("compound 1 pod3")
      ]
      service >> deployment >> pods

    ingress >> service
    deployment - configmap 
