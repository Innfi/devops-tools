#!/bin/zsh
kubectl describe daemonset aws-node -n kube-system | grep amazon-k8s-cni
