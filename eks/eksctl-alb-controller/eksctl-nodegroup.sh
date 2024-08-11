#!/bin/sh
eksctl create nodegroup \
--cluster alchemy \
--name alchemy-group \
--node-type t3.medium \
--nodes 2 \
--nodes-min 1 \
--nodes-max 3