#!/bin/sh
aws iam create-policy \
--policy-name AWSLoadBalancerControllerIAMPolicy \
--policy-document file://iam_policy.json

#arn:aws:iam::525017980305:policy/AWSLoadBalancerControllerIAMPolicy