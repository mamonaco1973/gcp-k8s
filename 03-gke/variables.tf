# ====================================================================
# IMAGE VERSION TO DEPLOY
# Controls which tagged version of your container image gets deployed
# Useful for promoting from dev → staging → prod
# ====================================================================
variable "image_version" {
  description = "Container image version to use"
  type        = string
  default     = "rc1"                         # 🔖 Default is 'rc1' — change to 'v1.0.0', 'latest', etc. as needed
}

# ====================================================================
# GCP REGION CONFIGURATION
# Must match where you provision other GCP services like subnets and GKE
# ====================================================================
variable "region" {
  description = "GCP region"
  type        = string
  default     = "us-central1"                # 🌍 Use the central region — change to 'europe-west1', etc. if needed
}

# ====================================================================
# GCP ZONE CONFIGURATION
# More specific than region — controls where GKE nodes live
# ====================================================================
variable "zone" {
  description = "GCP zone"
  type        = string
  default     = "us-central1-a"              # 📦 Your zonal GKE cluster and subnets live here
}

# ====================================================================
# GKE CLUSTER NAME
# This shows up in the GCP Console and influences node names, URLs, etc.
# Keep it short, lowercase, and unique in the region
# ====================================================================
variable "gke_cluster_name" {
  description = "Name of the GKE cluster"
  type        = string
  default     = "flask-gke"                  # 🐍 Named after your Flask app — avoid names that repeat 'gke-gke-gke'
}
