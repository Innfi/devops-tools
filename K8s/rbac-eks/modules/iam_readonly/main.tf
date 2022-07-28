resource "aws_iam_policy" "eks_readonly_policy" {
  name = "eks-readonly"

  policy = jsonencode({
    "Version": "2012-10-17"
    "Statement": [
      {
        "Action": [
          "eks:DescribeUser",
          "eks:ListCluster"
        ],
        "Effect": "Allow",
        "Resource": "*"
      }
    ]
  })
}

resource "aws_iam_user" "reader" {
  name = "eks_reader"
}

resource "aws_iam_user_policy_attachment" "attach_readonly" {
  user = aws_iam_user.reader.name
  policy_arn = aws_iam_policy.eks_readonly_policy.arn
}