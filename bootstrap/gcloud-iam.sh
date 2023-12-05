#!/bin/bash

PROJECT=$(gcloud config list --format 'value(core.project)' 2>/dev/null)

# Create a service account
# https://github.com/kubernetes/ingress-gce/tree/master/docs/deploy/gke/non-gcp#create-a-service-account
# create a service account
gcloud iam service-accounts create glbc-service-account \
  --display-name "Service Account for GLBC" --project $PROJECT

# binding compute.admin role to the service account
gcloud projects add-iam-policy-binding $PROJECT \
  --member serviceAccount:glbc-service-account@${PROJECT}.iam.gserviceaccount.com \
  --role roles/compute.admin

# Upload GCP Service Account Key as K8s Secret
# https://github.com/kubernetes/ingress-gce/tree/master/docs/deploy/gke/non-gcp#upload-gcp-service-account-key-as-k8s-secret
# Create key for glbc-service-account.
gcloud iam service-accounts keys create key.json --iam-account \
  glbc-service-account@${PROJECT}.iam.gserviceaccount.com

# Store the key as a secret in k8s. The secret will be mounted as a volume in
# glbc.yaml.
kubectl create secret generic glbc-gcp-key --from-file=key.json -n kube-system

rm -f key.json
