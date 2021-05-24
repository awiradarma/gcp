resource "google_compute_target_pool" "webserver_pool" {
  name = "instance-pool"

  health_checks = [
    google_compute_http_health_check.autohealing.name,
  ]
}

resource "google_compute_http_health_check" "autohealing" {
  name                = "autohealing-health-check"
  check_interval_sec  = 5
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 10 # 50 seconds
  request_path = "/"
}

resource "google_compute_region_instance_group_manager" "webserver" {
  name = "webserver-igm"

  base_instance_name         = "webserver-mig"
  region                     = var.region
  distribution_policy_zones  = ["us-central1-a", "us-central1-f"]

  version {
    instance_template = google_compute_instance_template.webserver_template.id
  }

  target_pools = [google_compute_target_pool.webserver_pool.id]
  target_size  = var.size

  auto_healing_policies {
    health_check      = google_compute_http_health_check.autohealing.id
    initial_delay_sec = 300
  }
}
