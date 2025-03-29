# ====================================================================
# GOOGLE CLOUD PROVIDER CONFIGURATION
# Connects Terraform to GCP using a service account key file.
# All GCP resources will be provisioned under this identity and project.
# ====================================================================
provider "google" {
  project     = local.credentials.project_id       # 🆔 Project ID pulled from your decoded credentials file
                                                   # 🔐 Do not hardcode this — use local context for reuse and portability

  credentials = file("../credentials.json")        # 📄 Full path to the service account key JSON
                                                   # ⚠️ Keep this file out of source control — treat it like a password
}

# ====================================================================
# LOCAL VARIABLES FOR GCP CREDENTIALS
# Parses and stores values from the service account key file.
# These locals are used everywhere else to keep config DRY and secure.
# ====================================================================
locals {
  credentials = jsondecode(file("../credentials.json"))  # 🧠 Decodes the raw JSON file into a usable map
                                                         # Contains keys like "project_id", "client_email", etc.

  service_account_email = local.credentials.client_email # 📬 Pulls out the service account email from the decoded map
                                                         # Used for IAM bindings and impersonation logic
}
