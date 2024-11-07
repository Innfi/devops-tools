#!/bin/zsh
kubectl run -it --rm debug --image=busybox --restart=Never -- sh
