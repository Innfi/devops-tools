resource "aws_s3_bucket" "resource" {
  bucket = "innfis-resource"
}

resource "aws_iam_policy" "s3_access_policy" {
  name = "eks_s3_policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject"
        ],
        Resource = [
          "arn:aws:s3:::${aws_s3_bucket.resource.bucket}",
          "arn:aws:s3:::${aws_s3_bucket.resource.bucket}/"
        ]
      }
    ]
  })
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type = "Federated"
      identifiers = [var.cluster_oidc_id]
    }

    condition {
      test = "StringEquals"
      variable = var.cluster_oidc_sub
      values = [var.cluster_serviceaccount_id]
    }
  }

  # additional statement definition for multi cluster
  # statement {
  # }
}

resource "aws_iam_role" "eks_s3_access_role" {
  name = "eks-s3-access-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "attach_s3_policy" {
  role = aws_iam_role.eks_s3_access_role.name
  policy_arn = aws_iam_policy.s3_access_policy.arn
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.resource.id 

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "AllowEKSRoleAccessOnly",
        Effect = "Deny",
        Principal = "",
        Action = "s3:*",
        Resource = ["arn:aws:s3:::${aws_s3_bucket.resource.bucket}/*"],
        Condition = {
          StringNotEquals = {
            "aws:PrincipalArn" = [
              aws_iam_role.eks_s3_access_role.arn
            ]
          }
        }
      }
    ]
  })
}