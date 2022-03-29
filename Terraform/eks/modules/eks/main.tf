resource "aws_iam_role" "eks-cluster-role" {
  name = "eks-cluster-role"

  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect" : "Allow",
        "Principal": {
          "Service": "eks.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cluster-policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role = aws_iam_role.eks-cluster-role.name
}

resource "aws_iam_role_policy_attachment" "vpc-resource-policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role = aws_iam_role.eks-cluster-role.name
}

resource "aws_iam_role_policy_attachment" "service-policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role = aws_iam_role.eks-cluster-role.name
}

resource "aws_iam_role" "eks-fargate-role" {
  name = "eks-fargate-role"

  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "eks-fargate-pods.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "fargate-policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
  role = aws_iam_role.eks-fargate-role.name
}

# resource "aws_security_group" "eks-cluster-self" {
#   vpc_id = var.vpc_id

#   tags = merge(
#     {
#       "Name" = format("%s-cluster-self", var.name)
#     },
#   )
# }

# resource "aws_security_group_rule" "ingress_self" {
#   security_group_id = aws_security_group.eks-cluster-self.id

#   type = "ingress"
#   from_port = 0
#   to_port = 0
#   protocol = -1
#   source_security_group_id = var.sg_id_public
# } 

# resource "aws_eks_cluster" "test-eks-cluster" {
#   name = var.cluster_name
#   role_arn = aws_iam_role.eks-cluster-role.arn
#   version = "1.21"

#   enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

#   vpc_config {
#     security_group_ids = [ var.sg_id_public ]
#     subnet_ids = var.subnet_id_public[*]
#     endpoint_private_access = false
#     endpoint_public_access = true
#   }

#   depends_on = [
#     aws_iam_role_policy_attachment.cluster-policy,
#     aws_iam_role_policy_attachment.vpc-resource-policy,
#     aws_iam_role_policy_attachment.service-policy
#   ]
# }

# resource "aws_eks_addon" "addon-vpc-cni" {
#   cluster_name = aws_eks_cluster.test-eks-cluster.name
#   addon_name = "vpc-cni"
#   resolve_conflicts = "OVERWRITE"
#   addon_version = "v1.10.1-eksbuild.1"
# }

# resource "aws_eks_addon" "addon-coredns" {
#   cluster_name = aws_eks_cluster.test-eks-cluster.name
#   addon_name = "coredns"
#   resolve_conflicts = "OVERWRITE"
#   addon_version = "v1.8.4-eksbuild.1"
# }

# resource "aws_eks_addon" "addon-kubeproxy" {
#   cluster_name = aws_eks_cluster.test-eks-cluster.name
#   addon_name = "kube-proxy"
#   resolve_conflicts = "OVERWRITE"
#   addon_version = "v1.21.2-eksbuild.2"
# }
