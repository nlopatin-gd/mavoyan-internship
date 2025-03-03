resource "google_compute_network" "lb_network" {
  name                    = "mavoyan-network"
  project                 = "gd-gcp-internship-devops"
  provider                = google-beta
  auto_create_subnetworks = false
}


resource "google_compute_subnetwork" "lb_subnet" {
  name          = "mavoyan-subnet"
  project       = "gd-gcp-internship-devops"
  provider      = google-beta
  ip_cidr_range = "10.0.2.0/24"
  region        = "us-east1"
  network       = google_compute_network.lb_network.id
}

resource "google_compute_global_address" "default" {
  provider = google-beta
  project  = "gd-gcp-internship-devops"
  name     = "mavoyan-static-ip"
}

resource "google_compute_global_forwarding_rule" "default" {
  name                  = "mavoyan-forwarding-rule"
  provider              = google-beta
  project               = "gd-gcp-internship-devops"
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL"
  port_range            = "80"
  target                = google_compute_target_http_proxy.default.id
  ip_address            = google_compute_global_address.default.id
}

resource "google_compute_target_http_proxy" "default" {
  name     = "mavoyan-target-http-proxy"
  project  = "gd-gcp-internship-devops"
  provider = google-beta
  url_map  = google_compute_url_map.default.id
}

resource "google_compute_url_map" "default" {
  name            = "mavoyan-url-map"
  project         = "gd-gcp-internship-devops"
  provider        = google-beta
  default_service = google_compute_backend_service.default.id
}


resource "google_compute_backend_service" "default" {
  name                    = "mavoyan-backend-service"
  project                 = "gd-gcp-internship-devops"
  provider                = google-beta
  protocol                = "HTTP"
  port_name               = "my-port"
  load_balancing_scheme   = "EXTERNAL"
  timeout_sec             = 10
  enable_cdn              = true
  custom_request_headers  = ["X-Client-Geo-Location: {client_region_subdivision}, {client_city}"]
  custom_response_headers = ["X-Cache-Hit: {cdn_cache_status}"]
  health_checks           = [google_compute_health_check.default.id]
  backend {
    group           = var.instance_group
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 1.0
  }
}

resource "google_compute_health_check" "default" {
  name     = "mavoyan-hc"
  project  = "gd-gcp-internship-devops"
  provider = google-beta
  http_health_check {
    port_specification = "USE_SERVING_PORT"
  }
}

resource "google_compute_firewall" "default" {
  name          = "mavoyan-fw"
  project  = "gd-gcp-internship-devops"
  provider      = google-beta
  direction     = "INGRESS"
  network       = google_compute_network.lb_network.id
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16", ] #add ip
  allow {
    protocol = "tcp"
    ports    = ["80", "8080"]
  }
  target_tags = ["allow-health-check"]
}

