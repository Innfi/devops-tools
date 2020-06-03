variable "users" {
    description = "create iam users" 
    type = list 
    default = ["ennfi", "innfi"]
}

resource "aws_iam_user" "dev_user" {
    count = length(var.users)
    name = element(var.users, count.index)
    path = "/dev/" 
    tags = {
        Name = "ec2-users"
    }
}

resource "aws_iam_group" "ec2Initiator" {
   name = "ec2Initiator" 
}

resource "aws_iam_group_policy_attachment" "ec2-policy" {
    group = aws_iam_group.ec2Initiator.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

resource "aws_iam_user_group_membership" "dev_group" {
    count = length(var.users)
    user = element(var.users, count.index)
    groups = [
        aws_iam_group.ec2Initiator.name
    ]
}
