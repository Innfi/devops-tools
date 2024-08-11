#!/bin/sh
eksctl utils associate-iam-oidc-provider \
--region ap-northeast-2 \
--cluster alchemy \
--approve
