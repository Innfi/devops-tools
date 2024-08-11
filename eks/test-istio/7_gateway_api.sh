kubectl get crd gateways.gateway.networking.k8s.io
kubectl kustomize "github.com/kubernetes-sigs/gateway-api/config/crd?ref=444631bfe06f3bcca5d0eadf1857eac1d369421d" | kubectl apply -f -;
istioctl install --set profile=minimal -y
