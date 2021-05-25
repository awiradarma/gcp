resource "google_compute_global_address" "ext-http-lb" {
  name = "my-address"
}

resource "google_compute_global_forwarding_rule" "ext-http-lb" {
  name       = "ext-http-lb-forwarding-rule"
  target     = google_compute_target_http_proxy.ext-http-lb.id
  ip_address    = google_compute_global_address.ext-http-lb.id
  port_range = "80"
}

resource "google_compute_target_http_proxy" "ext-http-lb" {
  name    = "http-proxy"
  url_map = google_compute_url_map.ext-http-lb.id
}

resource "google_compute_url_map" "ext-http-lb" {
  name            = "url-map"
  default_service = google_compute_backend_service.ext-http-lb.id

  host_rule {
    hosts        = ["*"]
    path_matcher = "allpaths"
  }

  path_matcher {
    name            = "allpaths"
    default_service = google_compute_backend_service.ext-http-lb.id

    path_rule {
      paths   = ["/*"]
      service = google_compute_backend_service.ext-http-lb.id
    }
  }
}

resource "google_compute_backend_service" "ext-http-lb" {
  load_balancing_scheme = "EXTERNAL"

  backend {
    group          = google_compute_region_instance_group_manager.ext-http-lb-us.instance_group
  }

  backend {
    group          = google_compute_region_instance_group_manager.ext-http-lb-asia.instance_group
  }
  
  backend {
    group          = google_compute_region_instance_group_manager.ext-http-lb-eu.instance_group
  }
  
  name        = "global-service"
  protocol    = "HTTP"
  timeout_sec = 10

  health_checks = [google_compute_health_check.ext-http-lb.id]
}

resource "google_compute_health_check" "ext-http-lb" {
  name                = "hc-health-check"
  check_interval_sec  = 5
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 10 # 50 seconds
  tcp_health_check {
    port = "80"
  }
}

resource "google_compute_http_health_check" "ext-http-lb-hc" {
  name                = "hc2-health-check"
  check_interval_sec  = 5
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 10 # 50 seconds
  request_path = "/"
}

resource "google_compute_region_instance_group_manager" "ext-http-lb-us" {
  name = "webserver-us"

  base_instance_name         = "webserver-us"
  region                     = "us-central1"
  distribution_policy_zones  = ["us-central1-a", "us-central1-f"]

  version {
    instance_template = google_compute_instance_template.webserver_template.id
  }

  target_size  = 1

  auto_healing_policies {
    health_check      = google_compute_http_health_check.ext-http-lb-hc.id
    initial_delay_sec = 300
  }
}

resource "google_compute_region_instance_group_manager" "ext-http-lb-asia" {
  name = "webserver-asia"

  base_instance_name         = "webserver-asia"
  region                     = "asia-southeast1"
  distribution_policy_zones  = ["asia-southeast1-a", "asia-southeast1-b"]

  version {
    instance_template = google_compute_instance_template.webserver_template.id
  }

  target_size  = 1

  auto_healing_policies {
    health_check      = google_compute_http_health_check.ext-http-lb-hc.id
    initial_delay_sec = 300
  }
}

resource "google_compute_region_instance_group_manager" "ext-http-lb-eu" {
  name = "webserver-eu"

  base_instance_name         = "webserver-eu"
  region                     = "europe-west1"
  distribution_policy_zones  = ["europe-west1-b", "europe-west1-c"]

  version {
    instance_template = google_compute_instance_template.webserver_template.id
  }

  target_size  = 1

  auto_healing_policies {
    health_check      = google_compute_http_health_check.ext-http-lb-hc.id
    initial_delay_sec = 300
  }
}

