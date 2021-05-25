output "load_balancer_ip" {
value = google_compute_global_forwarding_rule.ext-http-lb.ip_address
}
