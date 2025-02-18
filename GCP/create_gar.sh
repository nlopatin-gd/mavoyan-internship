#!/bin/bash

PROJECT_ID="gd-gcp-internship-devops" #$(gcloud config get-value project)
IMAGE_NAME='spring-app'
GAR_NAME='mavoyan-springrepo'
REGION='us-east1'

gcloud artifacts repositories create $GAR_NAME \
    --repository-format=docker \
    --location=$REGION \
    --description="Docker repository for Spring App"

gcloud auth configure-docker $REGION-docker.pkg.dev

docker build -t $IMAGE_NAME spring-petclinic

docker tag $IMAGE_NAME $REGION-docker.pkg.dev/$PROJECT_ID/$GAR_NAME/$IMAGE_NAME:latest

docker push $REGION-docker.pkg.dev/$PROJECT_ID/$GAR_NAME/$IMAGE_NAME:latest