resource "google_compute_instance" "web_server" {
  boot_disk {
    auto_delete = true
    device_name = "mavoyan-temp-vm"

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
    startup-script = "sudo apt update\nsudo apt install -y apache2\nsudo systemctl start apache2\nsudo systemctl enable apache2\nsudo apt install php libapache2-mod-php -y\nsudo rm /var/www/html/index.html\nsudo touch /var/www/html/index.php\necho \"<?php echo 'Hostname: ' . gethostname(); ?>\" | sudo tee /var/www/html/index.php\nsudo systemctl restart apache2"
  }

  name = "mavoyan-test-vm"

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
  name        = "mavoyan-vm-template"
  source_disk = google_compute_instance.web_server.boot_disk[0].source
  project     = "gd-gcp-internship-devops"

  depends_on = [null_resource.stop_vm]
}

resource "google_compute_instance_template" "instance_template" {
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
  name   = "mavoyan-lb-mig"
  region = "us-east1"
  version {
    instance_template = google_compute_instance_template.instance_template.id
    name              = "primary"
  }
  named_port {
    name = "http-server"
    port = 80
  }
  base_instance_name = "mavoyan-vm"
  target_size        = 3
}

