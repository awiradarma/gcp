## Terraform

#### Basic commands
- terraform init
- terraform plan
- terraform apply
- terraform show
- < change instance.tf like the VM name >
- terraform plan
- terraform apply
- terraform destroy
- terraform destroy -target google_compute_instance.default
- terraform refresh -- refresh content of tfstate file

#### Sample instance.tf
```
student_03_060cf52c2ca2@cloudshell:~ (qwiklabs-gcp-03-fc3fbf3f716b)$ cat instance.tf
resource "google_compute_instance" "default" {
  project      = "qwiklabs-gcp-03-fc3fbf3f716b"
  name         = "debian"
  machine_type = "n1-standard-1"
  zone         = "us-central1-a"
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }
  network_interface {
    network = "default"
    access_config {
    }
  }
}
```

#### GKE
```
cat > terraform.tfvars <<EOF
gke_username = "admin"
gke_password = "$(openssl rand -base64 16)"
EOF
```
