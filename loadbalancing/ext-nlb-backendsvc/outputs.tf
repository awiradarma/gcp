output "load_balancer_ip" {
# value = google_compute_address.ip_address.address
value = google_compute_forwarding_rule.backend.ip_address
}
