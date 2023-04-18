data "terraform_remote_state" "eks" {
  backend = "local"
  config = {
    path = "../terraform.tfstate"
  }
}

data "aws_eks_cluster" "cluster" {
  name = data.terraform_remote_state.eks.outputs.cluster_id
}

provider "helm" {
  kubernetes {
    host = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
    exec {
      api_version = "client.authentication.k8s.io/v1alpha1"
      args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.cluster.name]
      command     = "aws"
    }
  }
}

# provider "helm" {
#   kubernetes {
#     config_path = "~/.kube/config"
#   }
# }

resource "helm_release" "custom_release" {
  name = "custom_release"
  # helm_release = "https://charts.bitnami.com/bitnami"

  chart = "./chart"

  values = [
    file("${path.module}/chart/values.yaml")
  ]
}

resource "helm_release" "test" {
  name = "helm_test"
  namespace = "default"
  # repository = ""
  chart = "./test"

  set {
    name = "port"
    value = "3000"
  }

  set {
    name = "replicas"
    value = "2"
  }
}