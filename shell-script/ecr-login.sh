#!/bin/zsh
REGION=(target region)
ACCOUNT=$(aws sts get-caller-identity|jq .Account -r)

aws ecr get-login-password --region ap-northeast-2 | docker login --username AWS --password-stdin $ACCOUNT.dkr.ecr.$REGION.amazonaws.com
