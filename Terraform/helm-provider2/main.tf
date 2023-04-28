provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

resource "helm_release" "test" {
  name = "test"

  # namespace = var.cluster_namespace

  chart = "./test-chart"
}