variable "aws_region" {
  description = "AWS region where Bedrock resources will be created"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "my-project"
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 7
}

variable "enable_embedding_data_delivery" {
  description = "Enable embedding data delivery to CloudWatch and S3"
  type        = bool
  default     = true
}

variable "enable_image_data_delivery" {
  description = "Enable image data delivery to CloudWatch and S3"
  type        = bool
  default     = true
}

variable "enable_text_data_delivery" {
  description = "Enable text data delivery to CloudWatch and S3"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    ManagedBy = "Terraform"
    Service   = "Bedrock"
  }
}
