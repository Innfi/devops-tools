resource "aws_codepipeline" "masterband-pipeline" {
    name = "masterband-pipeline"
    role_arn = aws_iam_role.codepipeline_role.arn

    artifact_store {
        location = aws_s3_bucket.ProjectMasterband.bucket
        type = "S3"
    }   

    stage {
        name = "Source"

        action {
            name = "Source"
            category = "Source"
            owner = "AWS"
            provider = "CodeCommit"
            version = "1"

            configuration = {
                Owner = "innfi"
                Repo = "lambda-pipeline-repo"
                Branch = "master"
            }
        }
    }

    stage {
        name = "Build"

        action {
            name = "Build"
            category = "Build"
            owner = "AWS" 
            provider = "CodeBuild"
            version = "1"

            configuration = {
                ProjectName = "masterband-codebuild"
            }
        }
    }

    stage {
        name = "Deploy"

        action {
            name = "Deploy" 
            category = "Deploy" 
            owner = "AWS" 
            provider = "CodeDeploy"
            version = "1"
        }
    }   
}