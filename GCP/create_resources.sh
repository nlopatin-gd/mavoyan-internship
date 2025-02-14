#!/bin/bash

PROJECT_ID="gd-gcp-internship-devops" #$(gcloud config get-value project)
IMAGE_NAME='spring-app'
# Set project
gcloud config set project $PROJECT_ID

# Creation ofVPC
gcloud compute networks create mavoyan-vpc \
  --project=$PROJECT_ID \
  --subnet-mode=custom \
  --mtu=1460 \
  --bgp-routing-mode=regional \
  --bgp-best-path-selection-mode=legacy

# Creattion of subnet
gcloud compute networks subnets create mavoyan-subnet \
  --project=$PROJECT_ID \
  --range=10.0.0.0/24 \
  --stack-type=IPV4_ONLY \
  --network=mavoyan-vpc \
  --region=us-east1

# Enable GCR API
gcloud services enable artifactregistry.googleapis.com

# Creation firewall rule 
gcloud compute firewall-rules create mavoyan-allow-http-ssh \
  --project=$PROJECT_ID \
  --direction=INGRESS \
  --priority=1000 \
  --network=mavoyan-vpc \
  --action=ALLOW \
  --rules=tcp:22,tcp:80,tcp:8080 \
  --source-ranges=0.0.0.0/0 \
  --target-tags=simpletag

# Creation of external IP address
gcloud compute addresses create mavoyan-ipforvm \
  --project=$PROJECT_ID \
  --region=us-east1


# Creation of VM 
gcloud compute instances create mavoyan-vm \
    --project=$PROJECT_ID \
    --zone=us-east1-b \
    --machine-type=e2-medium \
    --network-interface=network-tier=PREMIUM,stack-type=IPV4_ONLY,subnet=mavoyan-subnet,address=mavoyan-ipforvm \
    --maintenance-policy=MIGRATE \
    --provisioning-model=STANDARD \
    --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/trace.append \
    --tags=simpletag \
    --create-disk=auto-delete=yes,boot=yes,device-name=vm-2,image=projects/ubuntu-os-cloud/global/images/ubuntu-2004-focal-v20250130,mode=rw,size=10,type=pd-balanced \
    --no-shielded-secure-boot \
    --shielded-vtpm \
    --shielded-integrity-monitoring \
    --labels=goog-ec-src=vm_add-gcloud \
    --reservation-affinity=any 

