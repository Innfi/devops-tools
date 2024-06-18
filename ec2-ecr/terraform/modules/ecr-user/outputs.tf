output "user_name" {
  value = aws_iam_user.starter_user.name
}

output "user_arn" {
  value = aws_iam_user.starter_user.arn
}
