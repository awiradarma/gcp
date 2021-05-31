output "gcr_location" {
  value = data.google_container_registry_repository.registry.repository_url
}
