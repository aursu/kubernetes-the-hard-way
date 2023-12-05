#!/bin/bash

PROJECT_ID=$(gcloud config list --format 'value(core.project)')
ACCOUNT_ID=$(gcloud config list --project $PROJECT_ID --format 'value(core.account)')
NETWORK_NAME=kubernetes-the-hard-way
SUBNETWORK_NAME=kubernetes
ZONE=$(gcloud config get-value compute/zone)

cp ingress-gce/docs/deploy/gke/non-gcp/*.conf ingress-gce/docs/deploy/gke/non-gcp/*.yaml .

# [Create K8s Roles](https://github.com/kubernetes/ingress-gce/tree/master/docs/deploy/gke/non-gcp#create-k8s-roles)
# Grant permission to current GCP user to create new k8s ClusterRoles.
kubectl create clusterrolebinding one-binding-to-rule-them-all \
  --clusterrole=cluster-admin \
  --user=$ACCOUNT_ID

kubectl create -f rbac.yaml

# [Create configmap for NEG controller](https://github.com/kubernetes/ingress-gce/tree/master/docs/deploy/gke/non-gcp#create-configmap-for-neg-controller)
# Fill in "project-id", "network-name", "local-zone" in gce.conf
sed -i -e "/api-endpoint/d" \
    -e "s/\[PROJECT\]/$PROJECT_ID/" \
    -e "s/\[NETWORK\]/$NETWORK_NAME/" \
    -e "s/\[ZONE\]/$ZONE/" gce.conf

# put the gce.conf to configmap
kubectl create configmap gce-config --from-file=gce.conf -n kube-system

# [Deploy NEG controller](https://github.com/kubernetes/ingress-gce/tree/master/docs/deploy/gke/non-gcp#deploy-neg-controller)
kubectl create -f default-http-backend.yaml
kubectl create -f glbc.yaml