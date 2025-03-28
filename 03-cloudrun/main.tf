# Google Cloud Provider Configuration
# This block sets up the Google Cloud provider in Terraform.
# It specifies the project ID and authentication credentials needed for resource provisioning.

provider "google" {
  project     = local.credentials.project_id # Uses the extracted project ID from the decoded JSON credentials file.
  credentials = file("../credentials.json")  # Reads the service account credentials from an external JSON file.
}

# Local Variables
# This section defines local variables to store extracted values from the credentials JSON file.

locals {
  credentials           = jsondecode(file("../credentials.json")) # Decodes the JSON file to access project and service account details.
  service_account_email = local.credentials.client_email          # Retrieves the service account email from the decoded JSON map.
}

# Google Cloud Run Service
# Deploys a Cloud Run service named "flask-app-service" in the "us-central1" region.

resource "google_cloud_run_service" "flask_service" {
  name     = "flask-app-service" # Defines the name of the Cloud Run service.
  location = "us-central1"       # Specifies the deployment region for the Cloud Run service.

  # Configuration for the container running inside Cloud Run
  template {
    spec {
      containers {
        image = "us-central1-docker.pkg.dev/${local.credentials.project_id}/flask-repository/flask-app:flask-app-${var.image_version}"
        # Sets the container image from Google Artifact Registry, dynamically referencing the project ID.

        ports {
          container_port = 8000 # Exposes port 8000 inside the container for HTTP traffic.
        }

        resources {
          limits = {
            cpu    = "250m"  # Allocates 0.25 vCPU (1000m = 1 CPU core) for the container.
            memory = "512Mi" # Allocates 512 MB of RAM for the container.
          }
        }
      }
    }

    metadata {
      annotations = {
        "autoscaling.knative.dev/minScale" = "1" # Ensures at least 1 instance is always running (prevents cold starts).
        "autoscaling.knative.dev/maxScale" = "3" # Limits the maximum number of running instances to 3.
      }
    }
  }

  # Traffic management for Cloud Run
  traffic {
    percent         = 100  # Routes 100% of traffic to the latest deployed revision.
    latest_revision = true # Always points traffic to the latest revision of the service.
  }
}

# IAM Configuration for Public Access
# Grants all users permission to invoke the Cloud Run service.
resource "google_cloud_run_service_iam_member" "public_access" {
  service  = google_cloud_run_service.flask_service.name     # References the Cloud Run service.
  location = google_cloud_run_service.flask_service.location # Uses the same region as the Cloud Run service.
  role     = "roles/run.invoker"                             # Assigns the "run.invoker" role, allowing invocation of the service.
  member   = "allUsers"                                      # Grants access to anyone on the internet (public access).
}

