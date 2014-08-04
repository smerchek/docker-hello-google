#!/bin/bash

# Exit on any error
set -e

KUBERNETES_VERSION=41eb15bcff4f114e95788f1e3a5ad3645c4e53fd

# Exit if already installed
if [[ -d ~/kubernetes ]]; then
  echo "Kubernetes already installed"
  exit 0
else
  echo "Installing Kubernetes..."
fi

# Clone repo
(cd ~ && git clone https://github.com/GoogleCloudPlatform/kubernetes.git)
(cd ~/kubernetes && git reset --hard $KUBERNETES_VERSION)

# Build go source
(cd ~/kubernetes && hack/build-go.sh)

