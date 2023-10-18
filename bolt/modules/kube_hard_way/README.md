# kube_hard_way

Proceed [Kubernetes The Hard Way](https://github.com/kelseyhightower/kubernetes-the-hard-way) using [Puppet Bolt](https://www.puppet.com/community/open-source/bolt)

## Table of Contents

1. [Description](#description)
1. [Setup - The basics of getting started with kube_hard_way](#setup)
    * [What kube_hard_way affects](#what-kube_hard_way-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with kube_hard_way](#beginning-with-kube_hard_way)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Development - Guide for contributing to the module](#development)

## Description

Puppet module to help to bootstrap Kubernetes cluster described in tutorial
[Kubernetes The Hard Way](https://github.com/kelseyhightower/kubernetes-the-hard-way)
using [Puppet](https://www.puppet.com/community/open-source) and
[Puppet Bolt](https://www.puppet.com/community/open-source/bolt)

## Setup

### What kube_hard_way affects **OPTIONAL**

The Bolt project root is located inside `bolt` directory. File
`bolt/inventory.yaml` must be updated with proper IP adresses for Kubernetes
hosts.

Therefore before proceeding with Bolt related steps infrastructure must be
provisioned first according to
[Prerequisites](https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/master/docs/01-prerequisites.md#prerequisites) and
[Provisioning Compute Resources](https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/master/docs/03-compute-resources.md#provisioning-compute-resources).

All IP addresses are available via command below (output field `EXTERNAL_IP`):

```
gcloud compute instances list --filter="tags.items=kubernetes-the-hard-way"
```

SSH private key is required to be set into file `keys/google_compute_engine.pem`
in order to access Kubernetes nodes via Bolt.

The bootstrap process relies on
[Bolt plans written in the Puppet language](https://www.puppet.com/docs/bolt/latest/writing_plans.html). Therefore Puppet agent is required on all Kubernetes nodes:

```
bolt plan run puppet::agent::install targets=kubernetes
```

### Setup Requirements **OPTIONAL**

To generate proper SSH keys for both `gcloud` and Puppet Bolt use next command:

```
ssh-keygen -t ed25519 -f ~/.ssh/google_compute_engine -C "gcloud"
```

and afterwards copy it into `keys/google_compute_engine.pem`:

```
cp -a ~/.ssh/google_compute_engine keys/google_compute_engine.pem
```

### Beginning with kube_hard_way

## Usage

Step [Provisioning a CA and Generating TLS Certificates](https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/master/docs/04-certificate-authority.md#provisioning-a-ca-and-generating-tls-certificates) is implemented via commands:

```
bolt plan run kubernetes::certificate::api
bolt plan run kubernetes::certificate::worker
```

Step [Generating Kubernetes Configuration Files for Authentication](https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/master/docs/05-kubernetes-configuration-files.md#generating-kubernetes-configuration-files-for-authentication) is implemented via commands:

```
bolt plan run kubernetes::config::api
bolt plan run kubernetes::config::worker
```

Step [Generating the Data Encryption Config and Key](https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/master/docs/06-data-encryption-keys.md#generating-the-data-encryption-config-and-key) covered by command:

```
bolt plan run kubernetes::config::enc
```

Step [Bootstrapping the etcd Cluster](https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/master/docs/07-bootstrapping-etcd.md#bootstrapping-the-etcd-cluster) could be done by command:

```
bolt plan run kubernetes::bootstrap::etcd
```

Next step [Bootstrapping the Kubernetes Control Plane](https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/master/docs/08-bootstrapping-kubernetes-controllers.md#bootstrapping-the-kubernetes-control-plane) will be completed after commands' run:

```
bolt plan run kubernetes::bootstrap::control_plain
```

But it is still necessary to proceed with task [Provision a Network Load Balancer](https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/master/docs/08-bootstrapping-kubernetes-controllers.md#provision-a-network-load-balancer) manually


The step [Bootstrapping the Kubernetes Worker Nodes](https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/master/docs/09-bootstrapping-kubernetes-workers.md#bootstrapping-the-kubernetes-worker-nodes) has implementation within Bolt plan `kubernetes::bootstrap::worker`:

```
bolt plan run kubernetes::bootstrap::worker
```

[Provisioning Pod Network Routes](https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/master/docs/11-pod-network-routes.md#provisioning-pod-network-routes) is manual step related to GCP routes setup.

And final step [Deploying the DNS Cluster Add-on](https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/master/docs/12-dns-addon.md#deploying-the-dns-cluster-add-on) is implemented via next command:

```
bolt plan run kubernetes::bootstrap::components
```

## Limitations

All steps related to GCP provisioning are manual.
