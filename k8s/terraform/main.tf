data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = "https://${google_container_cluster.default.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(google_container_cluster.default.master_auth[0].cluster_ca_certificate)

  ignore_annotations = [
    "^autopilot\\.gke\\.io\\/.*",
    "^cloud\\.google\\.com\\/.*"
  ]
}

terraform {
  backend "gcs" {
    bucket = "mavoyan-terraform-remote-backend"
  }
}

resource "google_compute_network" "default" {
  project = "gd-gcp-internship-devops"
  name = "mavoyan-network"

  auto_create_subnetworks  = false
}

resource "google_compute_subnetwork" "default" {
  project = "gd-gcp-internship-devops"
  name = "mavoyan-subnetwork"

  ip_cidr_range = "10.0.0.0/16"
  region        = "us-east1"

  stack_type       = "IPV4_IPV6"
  ipv6_access_type = "EXTERNAL" # Change to "EXTERNAL" if creating an external loadbalancer

  network = google_compute_network.default.id
  secondary_ip_range {
    range_name    = "services-range"
    ip_cidr_range = "192.168.0.0/24"
  }

  secondary_ip_range {
    range_name    = "pod-ranges"
    ip_cidr_range = "192.168.1.0/24"
  }
}

resource "google_container_cluster" "default" {
  project = "gd-gcp-internship-devops"
  name = "mavoyan-cluster"

  location                 = "us-east1"
  enable_autopilot         = true
  enable_l4_ilb_subsetting = true
  node_config {
    tags = ["allow-health-check"]
  }
  

  network    = google_compute_network.default.id
  subnetwork = google_compute_subnetwork.default.id

  ip_allocation_policy {
    stack_type                    = "IPV4_IPV6"
    services_secondary_range_name = google_compute_subnetwork.default.secondary_ip_range[0].range_name
    cluster_secondary_range_name  = google_compute_subnetwork.default.secondary_ip_range[1].range_name
  }
  deletion_protection = false
}

resource "google_compute_firewall" "default" {
  project = "gd-gcp-internship-devops"
  name          = "mavoyan-allow-hc"
  direction     = "INGRESS"
  network       = google_compute_network.default.id
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
  allow {
    protocol = "tcp"
  }
  target_tags = ["allow-health-check"]
}

# resource "google_compute_global_address" "default" {
#   project = "gd-gcp-internship-devops"
#   description = "Global IP address for GKE ingress"
#   name = "mavoyan-ingress-webapps"
# }