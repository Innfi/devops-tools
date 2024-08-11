#!/bin/sh
eksctl create iamserviceaccount \
--cluster=alchemy \
--namespace=kube-system \
--name=aws-load-balancer-controller \
--attach-policy-arn=arn:aws:iam::():policy/AWSLoadBalancerControllerIAMPolicy \
--override-existing-serviceaccounts \
--approve 
