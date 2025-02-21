resource "aws_iam_role" "eks-user-role" {
  name = "eks-user-role"

  assume_role_policy = jsonencode({
    "Version": "2012-10-17"
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Effect": "Allow",
        "Principal": {
          "AWS": "arn:aws:iam::${var.accountid}:root"
        }
      },
    ]
  })
}

resource "aws_iam_group" "manager" {
  name = "innfismanager"
}

resource "aws_iam_policy" "rbac-policy" {
  name = "rbac-policy" 

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Effect": "Allow",
        "Resource": "arn:aws:iam::${var.accountid}:role/eks-user-role"
      },
      {
        "Action": [
          "eks:ListClusters",
          "eks:ListNodeGroups",
          "eks:ListTagsForResource",
          "eks:ListAddons",
          "eks:DescribeNodeGroup",
          "eks:DescribeCluster",
          "eks:DescribeAddonVersions",
          "eks:AccessKubernetesApi",
        ],
        "Effect": "Allow",
        "Resource": "*"
      }
    ]
  })
}

resource "aws_iam_group_policy_attachment" "manager-policy" {
  group = aws_iam_group.manager.name

  policy_arn = aws_iam_policy.rbac-policy.arn
}

resource "aws_iam_group" "reader" {
  name = "innfisreader"
}

resource "aws_iam_user" "ennfi" {
  name = "ennfi"
}

resource "aws_iam_user_group_membership" "manager-group" {
  user = aws_iam_user.ennfi.name

  groups = [
    aws_iam_group.manager.name
  ]
}

resource "aws_iam_user_group_membership" "reader-group" {
  user = aws_iam_user.reader.name

  groups = [
    aws_iam_group.reader.name
  ]
}