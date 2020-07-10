resource "aws_codedeploy_app" "masterband-deploy" {
    compute_platform = "Lambda"
    name = "masterband"
}

resource "aws_codedeploy_deployment_group" "masterband-deployment-group" {
    app_name = aws_codedeploy_app.masterband-deploy.name
    deployment_group_name = "masterband-deployment-group"
    deployment_config_name = "CodeDeployDefault.LambdaAllAtOnce"
    service_role_arn = aws_iam_role.codedeploy_role.arn

    deployment_style {
        deployment_type = "BLUE_GREEN"
        deployment_option = "WITH_TRAFFIC_CONTROL"
    }
}