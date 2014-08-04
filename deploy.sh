#!/bin/bash

# Exit on any error
set -e

KUBE_CMD=${KUBERNETES_ROOT:-~/kubernetes}/cluster/kubecfg.sh

# Create credential files
envsubst < .kubernetes_auth.template > ~/.kubernetes_auth
# envsubst < .dockercfg.template > ~/.dockercfg

# Deploy image to private GCS-backed registry
docker push $EXTERNAL_REGISTRY_ENDPOINT/hello:$CIRCLE_SHA1

# Update Kubernetes replicationController
envsubst < kubernetes/rails-controller.json.template > rails-controller.json
$KUBE_CMD -c rails-controller.json \
    update replicationControllers/railscontroller

# Roll over Kubernetes pods
$KUBE_CMD rollingupdate railscontroller
