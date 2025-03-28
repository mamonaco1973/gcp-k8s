resource "google_artifact_registry_repository" "flask_repo" {
  provider      = google
  project       = local.credentials.project_id  
  location      = "us-central1"
  repository_id = "flask-repository"
  format        = "DOCKER"
  # Enable vulnerability scanning
  docker_config {
    immutable_tags = false
  }
}
