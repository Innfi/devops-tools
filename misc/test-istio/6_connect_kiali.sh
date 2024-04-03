#!/bin/sh
kubectl port-forward svc/kiali -n istio-system 20001:20001
