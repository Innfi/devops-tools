# AWS Bedrock Terraform Configuration

This Terraform configuration sets up AWS Bedrock resources with logging and monitoring capabilities.

## Resources Created

- **Model Invocation Logging Configuration**: Configures logging for Bedrock model invocations
- **CloudWatch Log Group**: Stores Bedrock logs
- **S3 Bucket**: Stores Bedrock logs with versioning and encryption
- **IAM Role & Policy**: Allows Bedrock to write logs to CloudWatch and S3

## Prerequisites

- Terraform >= 1.0
- AWS CLI configured with appropriate credentials
- AWS account with Bedrock service access enabled

## Usage

1. Copy the example variables file:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. Edit `terraform.tfvars` with your specific values

3. Initialize Terraform:
   ```bash
   terraform init
   ```

4. Review the execution plan:
   ```bash
   terraform plan
   ```

5. Apply the configuration:
   ```bash
   terraform apply
   ```

## Variables

| Name | Description | Default |
|------|-------------|---------|
| `aws_region` | AWS region for resources | `us-east-1` |
| `project_name` | Project name for naming resources | `my-project` |
| `environment` | Environment name (dev, staging, prod) | `dev` |
| `log_retention_days` | CloudWatch log retention in days | `7` |
| `enable_embedding_data_delivery` | Enable embedding data logging | `true` |
| `enable_image_data_delivery` | Enable image data logging | `true` |
| `enable_text_data_delivery` | Enable text data logging | `true` |
| `tags` | Tags to apply to all resources | See variables.tf |

## Outputs

- `bedrock_log_group_name`: CloudWatch Log Group name
- `bedrock_log_group_arn`: CloudWatch Log Group ARN
- `bedrock_logs_bucket_name`: S3 bucket name for logs
- `bedrock_logs_bucket_arn`: S3 bucket ARN
- `bedrock_logging_role_arn`: IAM role ARN for logging

## Notes

- Bedrock model access must be requested separately in the AWS Console
- The logging configuration applies to all Bedrock models in the region
- S3 bucket includes versioning and server-side encryption by default
