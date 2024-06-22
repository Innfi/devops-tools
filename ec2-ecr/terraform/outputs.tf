output "ecr_arn" {
  value = module.ecr_baseline.arn
}

output "user_name" {
  value = module.ecr_user.user_name
}

output "user_arn" {
  value = module.ecr_user.user_arn
}

output "ec2_public_dns" {
  value = module.ec2_baseline.ec2_baseline_public_dns
}
