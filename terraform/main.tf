module "network" {
  source         = "./modules/network"
  instance_group = module.compute.instance_group
}

module "compute" {
  source     = "./modules/compute"
  network_id = module.network.network_id
  subnet_id  = module.network.subnet_id
}

resource "google_storage_bucket" "default" {
  name     = "mavoyan-terraform-remote-backend"
  location = "US"

  force_destroy               = false
  public_access_prevention    = "enforced"
  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }
}

resource "local_file" "default" {
  file_permission = "0644"
  filename        = "${path.module}/backend.tf"

  content = <<-EOT
  terraform {
    backend "gcs" {
      bucket = "${google_storage_bucket.default.name}"
    }
  }
  EOT
}