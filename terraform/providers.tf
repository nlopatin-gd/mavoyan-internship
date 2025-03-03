terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.60"
    }
  }
}

provider "google" {
  project = "gd-gcp-internship-devops"
  region  = "europe-west1"
}