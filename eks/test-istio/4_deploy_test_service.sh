#!/bin/sh
if [ ! -f ./kubernetes-manifests.yaml ]
then
  curl https://raw.githubusercontent.com/GoogleCloudPlatform/microservices-demo/main/release/kubernetes-manifests.yaml  > kubernetes-manifests.yaml
fi

kubectl apply -f ./kubernetes-manifests.yaml
