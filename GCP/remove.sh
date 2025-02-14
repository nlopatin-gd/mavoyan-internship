#!/bin/bash

PROJECT_ID="gd-gcp-internship-devops" 
IMAGE_NAME='spring-app'
GAR_NAME='mavoyan-springrepo'
REGION='us-east1'
ZONE='us-east1-b'
VM_NAME='mavoyan-vm'
VPC_NAME='mavoyan-vpc'
SUBNET_NAME='mavoyan-subnet'
FIREWALL_RULE_NAME='mavoyan-allow-http-ssh'
IP_NAME='mavoyan-ipforvm'


gcloud config set project $PROJECT_ID


gcloud compute instances delete $VM_NAME \
    --project=$PROJECT_ID \
    --zone=$ZONE \
    --quiet

gcloud compute addresses delete $IP_NAME \
    --project=$PROJECT_ID \
    --region=$REGION \
    --quiet


gcloud compute firewall-rules delete $FIREWALL_RULE_NAME \
    --project=$PROJECT_ID \
    --quiet


gcloud compute networks subnets delete $SUBNET_NAME \
    --project=$PROJECT_ID \
    --region=$REGION \
    --quiet


gcloud compute networks delete $VPC_NAME \
    --project=$PROJECT_ID \
    --quiet


gcloud artifacts repositories delete $GAR_NAME \
    --project=$PROJECT_ID \
    --location=$REGION \
    --quiet

echo "All resources have been deleted successfully."
