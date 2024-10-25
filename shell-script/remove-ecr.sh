#!/bin/sh
aws ecr batch-delete-image --region $1 \
    --repository-name $2 \
    --image-ids "$(aws ecr list-images --region $1 --repository-name $2 --query 'imageIds[*]' --output json
)" || true


# aws ecr describe-images --repository-name $1|jq '.imageDetails[]| {imageDigest: .imageDigest, imagePushedAt: .imagePushedAt}'
