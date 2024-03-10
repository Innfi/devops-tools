resource "aws_s3_bucket" "test_bucket" {
  bucket = "test-bucket"

  tags = {
    Name = "test-bucket"
  }
}

resource "aws_security_group" "test_sg" {
  name = "test-sg"
  vpc_id = var.vpc_id
}

resource "aws_security_group_rule" "test_sg_rule" {
  security_group_id = aws_security_group.test_sg.id

  type = "ingress"

  from_port = 3000
  to_port = 3000
  protocol = -1

  cidr_blocks = var.ingress_cidr
}

resource "aws_instance" "test_instance" {
  ami = var.ami_id
  instance_type = var.instance_type
  key_name = var.key_pair
  subnet_id = var.subnet_id
  vpc_security_group_ids = [
    aws_security_group.test_sg.id
  ]

  tags = {
    Name = "test-instance"
  }
}

resource "aws_codedeploy_app" "test_deploy" {
  compute_platform = "Server"
  name = "test-deploy"
}

# TODO: CodeDeploy deployment group

resource "aws_iam_policy" "test_policy" {
  name = "test-policy"

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": [
          "s3:*"
        ],
        "Resource": [
          aws_s3_bucket.test_bucket.arn,
          "${aws_s3_bucket.test_bucket.arn}/*"
        ],
        "Effect": "Allow"
      },
      {
        "Action": [
          "ec2:*"
        ],
        "Resource": [
          aws_instance.test_instance.arn
        ],
        "Effect": "Allow"
      }
    ]
  })
}

resource "aws_iam_user" "test_user" {
  name = "test-user"
}

resource "aws_iam_user_policy_attachment" "test_attach" {
  user = aws_iam_user.test_user.name 
  policy_arn = aws_iam_policy.test_policy.arn
}