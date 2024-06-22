#!/bin/sh
cd ./terraform
ECR_ARN=$(terraform output -raw ecr_arn)
USER_ARN=$(terraform output -raw user_arn)
USER_NAME=$(terraform output -raw user_name)
EC2_DNS=$(terraform outout -raw ec2_public_dns)

echo $ECR_ARN

cd ../codebase

ACCOUNT=$(aws sts get-caller-identity|jq .Account -r)
aws ecr get-login-password --region ap-northeast-2 | docker login --username AWS --password-stdin $ACCOUNT.dkr.ecr.ap-northeast-2.amazonaws.com

docker build -t src-repo:latest .
docker tag src-repo:latest $ACCOUNT.dkr.ecr.ap-northeast-2.amazonaws.com/src-repo:latest
docker push $ACCOUNT.dkr.ecr.ap-northeast-2.amazonaws.com/src-repo:latest
