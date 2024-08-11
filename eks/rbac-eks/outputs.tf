output "cluster_arn" {
  value = module.eks.cluster_arn
}

output "cluster_id" {
  value = module.eks.cluster_id
}

output "user_arn" {
  value = module.iam_readonly.readonly_user.arn
}