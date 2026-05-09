#!/bin/sh
helm upgrade --install promtail grafana/promtail \
  -n monitoring \
  -f promtail-values.yaml
