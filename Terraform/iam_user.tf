resource "aws_iam_user" "ops_devenv" {
    name = "devenv"    
}

resource "aws_iam_access_key" "devenv_key" {
    user = aws_iam_user.ops_devenv.name
}

resource "aws_iam_user_policy" "devenv_policy" {
    name = "devenv_policy_ec2"
    user = aws_iam_user.ops_devenv.name 
    policy = <<EOF
        {
            "Statement": [
                {
                "Action": [
                    "ec2:Describe*"
                ],
                "Effect": "Allow",
                "Resource": "*"
                }
            ]
        }
    EOF
}