#!/bin/zsh
kubectl get services -n dev --output jsonpath='{.items[*].spec.ports[0].nodePort}{"\n"}'
