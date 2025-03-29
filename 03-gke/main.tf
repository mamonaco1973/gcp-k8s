# ====================================================================
# GOOGLE CLOUD PROVIDER SETUP
# ====================================================================

provider "google" {
  project     = local.credentials.project_id       # Project ID parsed from the credentials file
  credentials = file("../credentials.json")        # Path to service account key file (relative to working dir)
}

# ====================================================================
# LOCAL VARIABLES
# ====================================================================

locals {
  credentials           = jsondecode(file("../credentials.json"))  # Decode the JSON key for use throughout Terraform
  service_account_email = local.credentials.client_email           # Capture service account email for IAM bindings
}

# ====================================================================
# GOOGLE CLOUD DATA SOURCES
# ====================================================================

data "google_client_config" "default" {}
# ⚙️ Used to fetch the access token for Kubernetes provider auth

data "google_container_cluster" "primary" {
  name     = google_container_cluster.primary.name     # Dynamically reference the created cluster
  location = google_container_cluster.primary.location
  # 🗺️ This ensures the Kubernetes provider works even on the first apply (delayed resolution)
}
