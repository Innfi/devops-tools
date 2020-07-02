resource "aws_codebuild_project" "MasterbandBuild" {
    name = "masterband-codebuild"
    description = "codebuild project"
    build_timeout = "5" 
    queued_timeout = "5"

    service_role = aws_iam_role.codebuild_role.arn

    environment {
        compute_type = "BUILD_GENERAL1_SMALL"
        image = "aws/codebuild/standard:1.0"
        type = "LINUX_CONTAINER"
        image_pull_credentials_type = "CODEBUILD"
    }

    source {
        type = "CODECOMMIT"
        location = "ssh://git-codecommit.ap-northeast-2.amazonaws.com/v1/repos/lambda-pipeline-repo"
        git_clone_depth = 1 
    }

    source_version = "master"

    artifacts {
        type = "S3" 
        location=aws_s3_bucket.ProjectMasterband.bucket
        artifact_identifier = "/buildspec.yml"
    }
}