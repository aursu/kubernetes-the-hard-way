#!/bin/bash

PROJECT=$(gcloud config list --format 'value(core.project)' 2>/dev/null)

# create a service account
gcloud iam service-accounts create glbc-service-account \
  --display-name "Service Account for GLBC" --project $PROJECT

# binding compute.admin role to the service account
gcloud projects add-iam-policy-binding $PROJECT \
  --member serviceAccount:glbc-service-account@${PROJECT}.iam.gserviceaccount.com \
  --role roles/compute.admin

# Create key for glbc-service-account.
gcloud iam service-accounts keys create key.json --iam-account \
  glbc-service-account@${PROJECT}.iam.gserviceaccount.com

# Store the key as a secret in k8s. The secret will be mounted as a volume in
# glbc.yaml.
kubectl create secret generic glbc-gcp-key --from-file=key.json -n kube-system

rm -f key.json