resource "aws_iam_group" "ec2Initiator" {
   name = "ec2Initiator" 
}

resource "aws_iam_group_policy_attachment" "ec2-policy" {
    group = aws_iam_group.ec2Initiator.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"    
}