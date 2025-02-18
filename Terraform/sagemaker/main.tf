resource "aws_iam_role" "sagemaker_role" {
  name = "sagemaker_role"
  path = "/"
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect" : "Allow",
        "Principal": {
          "Service": "sagemaker.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_sagemaker_domain" "exmaple_domain" {
  domain_name = "test_domain"
  auth_mode = "IAM"
  vpc_id = var.vpc_id
  subnet_ids = var.subnet_ids

  default_user_settings {
    execution_role = aws_iam_role.sagemaker_role.arn
  }
}

resource "aws_sagemaker_user_profile" "example_profile" {
  domain_id = aws_sagemaker_domain.exmaple_domain.id
  user_profile_name = "example_profile"
}

resource "aws_sagemaker_app" "example" {
  domain_id = aws_sagemaker_domain.exmaple_domain.id
  user_profile_name = aws_sagemaker_user_profile.example_profile.user_profile_name
  app_name = "example_app"
  app_type = "JupyterServer"
}

resource "aws_sagemaker_notebook_instance" "example_notebook" {
  name = "example_notebook"
  role_arn = aws_iam_role.sagemaker_role.arn # correct?
  instance_type = "ml.t2.medium"
}