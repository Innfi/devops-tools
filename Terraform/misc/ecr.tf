resource "aws_kms_key" "test_key" {
	description = "test_key"
	deletion_window_in_days = 7
}

resource "aws_ecr_repository" "private_repo" {
	name = "private_repo"
  image_tag_mutability = "IMMUTABLE" #MUTABLE

	image_scanning_configuration {
		scan_on_push = true # false
	}

	encryption_configuration {
		encryption_type = "KMS" #AES256
		kms_key = aws_kms_key.test_key.arn
	}
}


resource "aws_ecr_lifecycle_policy" "lcp" {
	repository = aws_ecr_repository.private_repo.name

	policy = jsonencode({
		"rules": [
			{
				"rulePriority": 1,
				"description": "pruning rule"
				"selection": {
					"tagStatus": "untagged",
					"countType": "sinceImagePushed",
          "countUnit": "days",
          "countNumber": 180
        },
        "action": {
          "type": "expire"
        }
			}
		]
	})
}