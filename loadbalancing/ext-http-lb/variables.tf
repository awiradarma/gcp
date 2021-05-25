variable "project_id" {
  description = "Google Cloud Platform (GCP) Project ID."
  type        = string
}

variable "region" {
  description = "GCP region name."
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "GCP zone name."
  type        = string
  default     = "us-central1-a"
}

variable "name" {
  description = "Web server name."
  type        = string
}

variable "machine_type" {
  description = "GCP VM instance machine type."
  type        = string
  default     = "f1-micro"
}

variable "image" {
  description = "Image name to be used for the VM"
  type        = string
  default     = "webserver-image"
}

variable "size" {
  description = "Number of instances to be created in the target pool"
  type        = number
  default     = 2
}
