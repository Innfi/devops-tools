#!/usr/bin/bash
eksctl create iamserviceaccount --region ap-northeast-2 --cluster initial \
--namespace kube-system \
--name=alb-controller-sa \
--role-name LoadBalancerControllerRole \
--attach-policy-arn=arn::aws:iam:(account id):policy/AlbControllerPolicy \
--approve