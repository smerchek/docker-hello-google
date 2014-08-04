docker-hello-google
===================

This project demonstrates continuous delivery with [CircleCI](https://circleci.com) and [Google Compute Engine](https://cloud.google.com/products/compute-engine/) using [Docker](https://www.docker.com/) and [Kubernetes](https://github.com/GoogleCloudPlatform/kubernetes).

##Prerequisites

###A private Docker registry
This project assumes that a private Docker registry based on [google/docker-registry](https://registry.hub.docker.com/u/google/docker-registry/) available on GCE, which is accessible without authentication behind the GCE firewall and through a secure proxy to the public (http basic auth + SSL). (Note that this example project was tested with an unsecured endpoint because of [this issue](https://github.com/docker/docker/pull/5817). The registry setup should be easier as both Kubernetes and Docker add authentication options.

###A Kubernetes cluster
It is also assumed that a Kubernetes cluster is already setup. See the Kubernetes README for instructions on setting this up.

##Initial app deployment
Once all of the prerequisites are satisfied, the initial deployment can be performed as follows:

```bash
KUBE_ROOT=<the root of a clone of the Kubernetes repo>
HELLO_ROOT=<the root of this project>

# Create the Kubernetes replicationController
RAILS_SECRET=<secret> CIRCLE_SHA1=latest \
  INTERNAL_REGISTRY_ENDPOINT=<Docker registry endpoint accessible from GCE> \
  envsubst < $HELLO_ROOT/kubernetes/rails-controller.json.template > rails-controller.json
$KUBE_ROOT/cluster/kubecfg.sh -c rails-controller.json create replicationControllers

# Create the Kubernetes service--this will make the app available behind a GCE load balancer
# on port 8000. See https://github.com/GoogleCloudPlatform/kubernetes/issues/596 for a
# details on exposing services on standard ports
$KUBE_ROOT/cluster/kubecfg.sh -c $HELLO_ROOT/kubernetes/rails-service.json create services
```

See the [CircleCI Docker docs](https://circleci.com/docs/docker) for more information about using Docker
on CircleCI.
