#!/bin/bash

PROJECT_ID=$(gcloud config list --format 'value(core.project)')

# [Create a service account](https://github.com/kubernetes/ingress-gce/tree/master/docs/deploy/gke/non-gcp#create-a-service-account)
# create a service account
gcloud iam service-accounts describe glbc-service-account@${PROJECT_ID}.iam.gserviceaccount.com || {
  gcloud iam service-accounts create glbc-service-account \
    --display-name "Service Account for GLBC" --project $PROJECT_ID

  # binding compute.admin role to the service account
  gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member serviceAccount:glbc-service-account@${PROJECT_ID}.iam.gserviceaccount.com \
    --role roles/compute.admin
}

kubectl get -n kube-system secret/glbc-gcp-key || {
  # [Upload GCP Service Account Key as K8s Secret](https://github.com/kubernetes/ingress-gce/tree/master/docs/deploy/gke/non-gcp#upload-gcp-service-account-key-as-k8s-secret)
  # Create key for glbc-service-account.
  gcloud iam service-accounts keys create key.json --iam-account \
    glbc-service-account@${PROJECT_ID}.iam.gserviceaccount.com

  # Store the key as a secret in k8s. The secret will be mounted as a volume in
  # glbc.yaml.
  kubectl create secret generic glbc-gcp-key \
    --from-file=key.json -n kube-system --dry-run=client -o yaml |
  kubectl apply -f -

  rm -f key.json
}