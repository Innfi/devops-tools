resource "aws_iam_user" "ops_devenv" {
    name = "devenv"    
}

resource "aws_iam_access_key" "devenv_key" {
    user = aws_iam_user.ops_devenv.name
}

data "aws_iam_policy_document" "devenv_policy_document" {
    statement {
        actions = ["ecs:Describe"] 
        effect = "Allow"
        resources = ["*"]
    }
}

resource "aws_iam_user_policy" "devenv_policy" {
    name = "devenv_policy_ec2"
    user = aws_iam_user.ops_devenv.name 
    policy = data.aws_iam_policy_document.devenv_policy_document.json
}