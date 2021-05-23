resource "google_compute_instance" "webserver" {
  project      = var.project_id
  name         = var.name
  machine_type = var.machine_type
  zone         = var.zone

  tags = ["http-server"]
  boot_disk {
    initialize_params {
      image = var.image
    }
  }
  metadata_startup_script = "${file("startup_script.txt")}"
  network_interface {
    network = "default"
    access_config {
    }
  }
}

