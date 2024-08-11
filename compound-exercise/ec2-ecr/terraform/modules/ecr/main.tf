resource "aws_ecr_repository" "repo_baseline" {
  name = "src-repo"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }
}