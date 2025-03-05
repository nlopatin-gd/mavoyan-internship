output "network_id" {
  description = "The network ID"
  value       = google_compute_network.lb_network.id
}

output "subnet_id" {
  description = "The subnet ID"
  value       = google_compute_subnetwork.lb_subnet.id
}



