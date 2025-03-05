resource "google_compute_network" "lb_network" {
  description             = "Network for Load Balancer"
  name                    = "mavoyan-network"
  project                 = "gd-gcp-internship-devops"
  provider                = google-beta
  auto_create_subnetworks = false
}


resource "google_compute_subnetwork" "lb_subnet" {
  description   = "Subnetwork for Load Balancer"
  name          = "mavoyan-subnet"
  project       = "gd-gcp-internship-devops"
  provider      = google-beta
  ip_cidr_range = "10.0.2.0/24"
  region        = "us-east1"
  network       = google_compute_network.lb_network.id
}


resource "google_compute_firewall" "default" {
  description   = "Firewall for allowing health check and limiting IP and port ranges"
  name          = "mavoyan-fw"
  project       = "gd-gcp-internship-devops"
  provider      = google-beta
  direction     = "INGRESS"
  network       = google_compute_network.lb_network.id
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"] #add ip
  allow {
    protocol = "tcp"
    ports    = ["80", "8080"]
  }
  target_tags = ["allow-health-check"]
}