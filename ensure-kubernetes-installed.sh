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

# Download and unzip
wget -O ~/kubernetes.tar.gz \
  https://github.com/GoogleCloudPlatform/kubernetes/archive/$KUBERNETES_VERSION.tar.gz
tar -xz ~/kubernetes.tar.gz

# Build go source
$(cd ~/kubernetes && hack/build-go.sh)

