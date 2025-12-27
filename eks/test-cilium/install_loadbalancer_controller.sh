#!/bin/bash
eksctl create iamserviceaccount \
--cluster=my-cluster \
--namespace=kube-system \
--name=aws-load-balancer-controller \
--attach-policy-arn=arn:aws:iam::<AWS_ACCOUNT_ID>:policy/AWSLoadBalancerControllerIAMPolicy \
--approve
# TODO: can eks-pod-identity-agent replace irsa for aws-load-balancer-controller?

helm repo add eks https://aws.github.io/eks-charts
helm repo update

helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  --set clusterName=my-cluster \
  -n kube-system \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller
  --set region=ap-northeast-2 
