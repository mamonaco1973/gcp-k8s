# Google Cloud Provider Configuration
# Configures the Google Cloud provider using project details and credentials from a JSON file.
provider "google" {
  project     = local.credentials.project_id             # Specifies the project ID extracted from the decoded credentials file.
  credentials = file("../credentials.json")               # Path to the credentials JSON file for Google Cloud authentication.
}

# Local Variables
# Reads and decodes the credentials JSON file to extract useful details like project ID and service account email.
locals {
  credentials            = jsondecode(file("../credentials.json"))  # Decodes the JSON file into a map for easier access.
  service_account_email  = local.credentials.client_email          # Extracts the service account email from the decoded JSON map.
}

# Generate a random string for the bucket name
resource "random_string" "bucket_suffix" {
  length  = 6
  upper   = false
  special = false
  numeric = false
}

# Create the GCS bucket for remote state
resource "google_storage_bucket" "terraform_state" {
  name     = "terraform-state-${random_string.bucket_suffix.result}" # Unique bucket name
  location = "us-central1"
  force_destroy = true  # Allow deletion of the bucket even if it contains objects.
  # Enable versioning for the bucket
  versioning {
    enabled = true
  }
}

# Generate a file with the backend configuration
resource "local_file" "backend_config_gar" {
  filename = "../01-gar/01-gar-backend.tf"
  content  = <<-EOT
    terraform {
      backend "gcs" {
        bucket = "${google_storage_bucket.terraform_state.name}"
        prefix = "terraform/01-gar/state"
      }
    }
  EOT
}  

# Generate a file with the backend configuration
resource "local_file" "backend_config_cloudrun" {
  filename = "../03-cloudrun/03-cloudrun-backend.tf"
  content  = <<-EOT
    terraform {
      backend "gcs" {
        bucket = "${google_storage_bucket.terraform_state.name}"
        prefix = "terraform/03-cloudrun/state"
      }
    }
  EOT
}

