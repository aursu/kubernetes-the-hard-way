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
gcloud compute firewall-rules create kubernetes-the-hard-way-allow-external \
    --allow tcp:22,tcp:6443,icmp \
    --network kubernetes-the-hard-way \
    --source-ranges 37.201.128.0/17
gcloud compute addresses create kubernetes-the-hard-way \
    --region $(gcloud config get-value compute/region)