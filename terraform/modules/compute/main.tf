resource "google_compute_instance" "web_server" {
  description = "Temporarty VM for making image"
  boot_disk {
    auto_delete = true
    device_name = "${var.name}-temp-vm"  

    initialize_params {
      image = "projects/ubuntu-os-cloud/global/images/ubuntu-2404-noble-amd64-v20250228"
      size  = 10
      type  = "pd-balanced"
    }

    mode = "READ_WRITE"
  }

  can_ip_forward      = false
  deletion_protection = false
  enable_display      = false
  project =  "gd-gcp-internship-devops"

  labels = {
    goog-ec-src = "vm_add-tf"
  }

  machine_type = "e2-medium"

   metadata = {
    startup-script = var.startup_script
  }

  name = "${var.name}-test-vm"

  network_interface {
    access_config {
      network_tier = "PREMIUM"
    }

    queue_count = 0
    stack_type  = "IPV4_ONLY"
    subnetwork  = "projects/gd-gcp-internship-devops/regions/us-east1/subnetworks/default"
  }

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
    preemptible         = false
    provisioning_model  = "STANDARD"
  }

  service_account {
    email  = "71936227901-compute@developer.gserviceaccount.com"
    scopes = ["https://www.googleapis.com/auth/devstorage.read_only", "https://www.googleapis.com/auth/logging.write", "https://www.googleapis.com/auth/monitoring.write", "https://www.googleapis.com/auth/service.management.readonly", "https://www.googleapis.com/auth/servicecontrol", "https://www.googleapis.com/auth/trace.append"]
  }

  shielded_instance_config {
    enable_integrity_monitoring = true
    enable_secure_boot          = false
    enable_vtpm                 = true
  }

  zone = "us-east1-b"
}

resource "null_resource" "stop_vm" {
  provisioner "local-exec" {
    command = "gcloud compute instances stop ${google_compute_instance.web_server.name} --zone=${google_compute_instance.web_server.zone}"
  }

  depends_on = [google_compute_instance.web_server]
}


resource "google_compute_image" "image" {
  description = "Image for MIG instances"
  name        = "${var.name}-vm-template"
  source_disk = google_compute_instance.web_server.boot_disk[0].source
  project     = "gd-gcp-internship-devops"

  depends_on = [null_resource.stop_vm]
}

resource "google_compute_instance_template" "instance_template" {
  description = "Template for MIG instances"
  name_prefix  = "instance-template-"
  machine_type = "e2-micro"
  region       = "us-east1"
  tags         = ["allow-health-check"]

  disk {
    source_image = google_compute_image.image.self_link
  }

  network_interface {
    network    = var.network_id
    subnetwork = var.subnet_id
  }
  lifecycle {
    create_before_destroy = true
  }
}


resource "google_compute_region_instance_group_manager" "servers" {
  description = "MIG as the backend for the Load Balancer"
  name   = "${var.name}-lb-mig"
  region = "us-east1"
  distribution_policy_zones  = var.zones
  version {
    instance_template = google_compute_instance_template.instance_template.id
    name              = "primary"
  }
  named_port {
    name = "http-server"
    port = 80
  }
  base_instance_name = "${var.name}-vm"
  target_size        = 3
}


resource "google_compute_backend_service" "default" {
  description = "Backend Service for Load Balancer"
  name                    = "${var.name}-backend-service"
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
    group           = google_compute_region_instance_group_manager.servers.instance_group
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 1.0
  }
}


resource "google_compute_global_forwarding_rule" "default" {
  description = "Forwarding Rule for Load Balancer"
  name                  = "${var.name}-forwarding-rule"
  provider              = google-beta
  project               = "gd-gcp-internship-devops"
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL"
  port_range            = "80"
  target                = google_compute_target_http_proxy.default.id
  ip_address            = google_compute_global_address.address.id
}

resource "google_compute_target_http_proxy" "default" {
  description = "HTPP proxy for load balancer"
  name     = "${var.name}-target-http-proxy"
  project  = "gd-gcp-internship-devops"
  provider = google-beta
  url_map  = google_compute_url_map.default.id
}

resource "google_compute_url_map" "default" {
  description = "URL map for Load Balancer"
  name            = "${var.name}-url-map"
  project         = "gd-gcp-internship-devops"
  provider        = google-beta
  default_service = google_compute_backend_service.default.name
}


resource "google_compute_health_check" "default" {
  description = "Health check for backend service"
  name     = "${var.name}-hc"
  project  = "gd-gcp-internship-devops"
  provider = google-beta
  http_health_check {
    port_specification = "USE_SERVING_PORT"
  }
}

resource "google_compute_global_address" "address" {
  description = "Global address for Load Balancer"
  provider = google-beta
  project  = "gd-gcp-internship-devops"
  name     = "${var.name}-static-ip"
}

