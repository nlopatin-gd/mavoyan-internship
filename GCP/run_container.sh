#!/bin/bash

gcloud compute ssh mavoyan-vm --zone=us-east1-b --project=gd-gcp-internship-devops --command "
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-cegrtificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \"deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \$(lsb_release -cs) stable\" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER
gcloud auth configure-docker us-east1-docker.pkg.dev
docker pull us-east1-docker.pkg.dev/gd-gcp-internship-devops/mavoyan-springrepo/spring-app:latest
sudo docker run -d -p 8080:8080 us-east1-docker.pkg.dev/gd-gcp-internship-devops/mavoyan-springrepo/spring-app
sudo docker ps
"


