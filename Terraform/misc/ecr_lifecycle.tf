resource "aws_ecr_lifecycle_policy" "lifecycle_days" {
  for_each = toset(var.repository_days)
	repository = each.key

	policy = jsonencode({
		"rules": [
			{
				"rulePriority": 1,
				"description": "pruning rule - since image pushed"
				"selection": {
					"tagStatus": "untagged",
					"countType": "sinceImagePushed",
          "countUnit": "days",
          "countNumber": var.days_threshold
        },
        "action": {
          "type": "expire"
        }
			}
		]
	})
}

resource "aws_ecr_lifecycle_policy" "lifecycle_counts" {
  for_each = toset(var.repository_counts)
	repository = each.key

	policy = jsonencode({
		"rules": [
			{
				"rulePriority": 1,
				"description": "pruning rule - image count more than"
				"selection": {
					"tagStatus": "any",
					"countType": "imageCountMoreThan",
          "countUnit": "days",
          "countNumber": var.count_threshold
        },
        "action": {
          "type": "expire"
        }
			}
		]
	})
}