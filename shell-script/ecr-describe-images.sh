#!/bin/sh
aws ecr describe-images --repository-name $1|jq '.imageDetails[]| {imageDigest: .imageDigest, imagePushedAt: .imagePushedAt}'
