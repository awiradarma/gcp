resource "google_compute_instance_template" "webserver_template" {
  name        = "webserver-template"
  description = "This template is used to create web server instances."
  project      = var.project_id

  tags = ["http-server", "bar"]
  disk {
    source_image      = var.image
    auto_delete       = true
    boot              = true
  }

  labels = {
    environment = "dev"
  }

  instance_description = "description assigned to instances"
  machine_type         = var.machine_type
  can_ip_forward       = false

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }

  network_interface {
    network = "default"
    access_config  {
      nat_ip = null
      network_tier = "PREMIUM"
    }
  }


  metadata_startup_script = "${file("startup_script.txt")}"
  metadata = {
    foo = "bar"
  }

}

