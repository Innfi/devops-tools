#!/usr/bin/bash
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
--version 1.4.1 \
-n kube-system \
--set region=ap-northeast-2 \
--set clusterName=initial \
--set serviceAccount.create=false \
--set serviceAccount.name=alb-controller-sa
