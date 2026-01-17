#!/bin/bash

# Create a test network namespace if it doesn't exist
if ! ip netns list | grep -q "^test-ns"; then
  sudo ip netns add test-ns
fi

# Run ADD
export CNI_COMMAND=ADD
export CNI_CONTAINERID=tester-innfisid
export CNI_NETNS=/var/run/netns/test-ns
export CNI_IFNAME=eth0
export CNI_PATH=./

# Call the plugin with network config on stdin
cat <<EOF | ./test-cni-plugin
{
  "cniVersion": "1.0.0",
  "name": "mynet",
  "type": "test-cni-plugin",
  "bridge": "cni0",
  "subnet": "10.244.0.0/24",
  "ipam": {
    "type": "host-local",
    "subnet": "10.244.0.0/24"
  }
}
EOF
