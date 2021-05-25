output "load_balancer_ip" {
# value = google_compute_address.ip_address.address
value = google_compute_forwarding_rule.default.ip_address
}
