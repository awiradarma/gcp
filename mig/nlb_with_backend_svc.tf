#resource "google_compute_address" "ip_address" {
#  name = "my-address"
#}

resource "google_compute_forwarding_rule" "backend" {
  name       = "website-forwarding-rule-to-backend-svc"
  backend_service = google_compute_region_backend_service.default.id
#  ip_address    = google_compute_address.ip_address.id
  port_range = "80"
}

resource "google_compute_region_backend_service" "default" {
  load_balancing_scheme = "EXTERNAL"

  backend {
    group          = google_compute_region_instance_group_manager.webserver_1.instance_group
  }

  name        = "region-service"
  protocol    = "TCP"
  timeout_sec = 10

  health_checks = [google_compute_region_health_check.hc3.id]
}

resource "google_compute_region_health_check" "hc3" {
  name                = "hc-health-check"
  check_interval_sec  = 5
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 10 # 50 seconds
  tcp_health_check {
    port = "80"
  }
}

resource "google_compute_http_health_check" "hc2" {
  name                = "hc2-health-check"
  check_interval_sec  = 5
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 10 # 50 seconds
  request_path = "/"
}

resource "google_compute_region_instance_group_manager" "webserver_1" {
  name = "webserver-igm-1"

  base_instance_name         = "webserver-mig-1"
  region                     = var.region
  distribution_policy_zones  = ["us-central1-a", "us-central1-f"]

  version {
    instance_template = google_compute_instance_template.webserver_template.id
  }

  target_size  = var.size

  auto_healing_policies {
    health_check      = google_compute_http_health_check.hc2.id
    initial_delay_sec = 300
  }
}
