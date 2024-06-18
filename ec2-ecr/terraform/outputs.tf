output "ecr_arn" {
  value = module.ecr_baseline.arn
}

output "user_name" {
  value = module.ecr_user.user_name
}

output "user_arn" {
  value = module.ecr_user.user_arn
}