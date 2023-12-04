#!/bin/bash

# gce.conf
PROJECT_ID=$(gcloud config list --format 'value(core.project)' 2>/dev/null)
NETWORK_NAME=kubernetes-the-hard-way
SUBNETWORK_NAME=kubernetes
ZONE=$(gcloud config get-value compute/zone)

cp ingress-gce/docs/deploy/gke/non-gcp/gce.conf gce.conf

sed -i "/api-endpoint/d" gce.conf
sed -i "s/\[PROJECT\]/$PROJECT_ID/" gce.conf
sed -i "s/\[NETWORK\]/$NETWORK_NAME/" gce.conf
sed -i "s/\[SUBNETWORK\]/$SUBNETWORK_NAME/" gce.conf
sed -i "s/\[ZONE\]/$ZONE/" gce.conf