data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]
    }

    actions = [
      "sts:AssumeRole",
      "sts:TagSession"
    ]
  }
}

resource "aws_iam_role" "s3_access" {
  name = "eks-pod-identity-s3-access"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "s3_access_attachment" {
  role       = aws_iam_role.s3_access.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

resource "aws_eks_pod_identity_association" "s3_access_association" {
  cluster_name = var.cluster_name
  namespace    = var.namespace
  service_account = var.service_account
  role_arn     = aws_iam_role.s3_access.arn
}

# TODO: merge with s3 access?
resource "aws_iam_role" "ebs_access" {
  name = "eks-pod-identity-ebs-access"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "ebs_access_attachment" {
  role = aws_iam_role.ebs_access
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

resource "aws_eks_pod_identity_association" "ebs_access_association" {
  cluster_name = var.cluster_name
  namespace    = var.namespace
  service_account = var.service_account
  role_arn     = aws_iam_role.ebs_access.arn
}