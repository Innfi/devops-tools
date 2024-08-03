#!/bin/zsh
POD_IP=$(kubectl get po --selector app.kubernetes.io/component=service -n target-namespace -o json|jq -r '.items[0].spec.nodeName')
kubectl debug node/$POD_IP -it --image=ubuntu
