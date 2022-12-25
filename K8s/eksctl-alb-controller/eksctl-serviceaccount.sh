#!/bin/sh
eksctl create iamserviceaccount \
--cluster=alchemy \
--namespace=kube-system \
--name=aws-load-balancer-controller \
--attach-policy-arn=arn:aws:iam::525017980305:policy/AWSLoadBalancerControllerIAMPolicy \
--override-existing-serviceaccounts \
--approve 
