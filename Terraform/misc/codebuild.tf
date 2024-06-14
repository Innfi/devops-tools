resource "aws_codebuild_project" "innfisbuild" {
    name = "innfis-build"
    description = "test codebuild project with terraform"
    build_timeout = "5"
    service_role = "arn:aws:iam::525017980305:role/service-role/codebuild-lambda-codebuild-service-role"

    source {
        type = "CODECOMMIT"
        location = "ssh://git-codecommit.ap-northeast-2.amazonaws.com/v1/repos/lambda-pipeline-repo"
        git_clone_depth = 1

        auth {
            type = "OAUTH"
        }

        git_submodules_config {
            fetch_submodules = true
        }
    }

    source_version = "master"

    environment {
        compute_type = "BUILD_GENERAL1_SMALL"
        image = "aws/codebuild/standard:3.0"
        type = "LINUX_CONTAINER"
        image_pull_credentials_type = "CODEBUILD"
    }

    artifacts {
        type = "S3"
        name = "TfBuild/Test.zip"
        path = "innfislambda-codepipeline"
        packaging = "ZIP"
    }
}