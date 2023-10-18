#!/bin/bash

gcloud config set compute/region us-west1
gcloud config set compute/zone us-west1-c
gcloud compute networks create kubernetes-the-hard-way --subnet-mode custom
gcloud compute networks subnets create kubernetes \
    --network kubernetes-the-hard-way \
    --range 10.240.0.0/24
gcloud compute firewall-rules create kubernetes-the-hard-way-allow-internal \
    --allow tcp,udp,icmp \
    --network kubernetes-the-hard-way \
    --source-ranges 10.240.0.0/24,10.200.0.0/16
# https://www.gstatic.com/ipranges/cloud.json
gcloud compute firewall-rules create kubernetes-the-hard-way-allow-external \
    --allow tcp:22,tcp:6443,icmp \
    --network kubernetes-the-hard-way \
    --source-ranges 37.201.128.0/17,34.82.0.0/15,34.127.0.0/17,34.168.0.0/15,35.230.0.0/17,35.247.0.0/17,104.198.96.0/20

gcloud compute firewall-rules list --filter="network:kubernetes-the-hard-way"

gcloud compute addresses create kubernetes-the-hard-way \
    --region $(gcloud config get-value compute/region)

gcloud compute addresses list --filter="name=('kubernetes-the-hard-way')"

./gcloud-kubernetes-controllers.sh
./gcloud-kubernetes-workers.sh

gcloud compute instances list --filter="tags.items=kubernetes-the-hard-way"

# https://cloud.google.com/load-balancing/docs/health-check-concepts
gcloud compute http-health-checks create kubernetes \
    --description "Kubernetes Health Check" \
    --host "kubernetes.default.svc.cluster.local" \
    --request-path "/healthz"
# https://cloud.google.com/load-balancing/docs/health-checks#fw-netlb
gcloud compute firewall-rules create kubernetes-the-hard-way-allow-health-check \
    --network kubernetes-the-hard-way \
    --source-ranges 209.85.152.0/22,209.85.204.0/22,35.191.0.0/16 \
    --allow tcp
# https://cloud.google.com/load-balancing/docs/network
# https://cloud.google.com/load-balancing/docs/target-pools
gcloud compute target-pools create kubernetes-target-pool \
    --http-health-check kubernetes
gcloud compute target-pools add-instances kubernetes-target-pool \
    --instances controller-0,controller-1,controller-2
# https://cloud.google.com/load-balancing/docs/forwarding-rule-concepts
KUBERNETES_PUBLIC_ADDRESS=$(gcloud compute addresses describe kubernetes-the-hard-way \
    --region $(gcloud config get-value compute/region) \
    --format 'value(address)')
gcloud compute forwarding-rules create kubernetes-forwarding-rule \
    --address ${KUBERNETES_PUBLIC_ADDRESS} \
    --ports 6443 \
    --region $(gcloud config get-value compute/region) \
    --target-pool kubernetes-target-pool

./gcloud-routes.sh
