#!/bin/bash

for i in 0 1 2; do
  gcloud compute routes describe kubernetes-route-10-200-${i}-0-24 ||
    gcloud compute routes create kubernetes-route-10-200-${i}-0-24 \
      --network kubernetes-the-hard-way \
      --next-hop-address 10.240.0.2${i} \
      --destination-range 10.200.${i}.0/24
done

gcloud compute routes list --filter "network: kubernetes-the-hard-way"
