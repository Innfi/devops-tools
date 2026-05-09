#!/bin/sh
helm repo add grafana https://grafana.github.io/helm-charts
helm upgrade --install loki grafana/loki \
  -n monitoring \
  -f ./loki-values.yaml
