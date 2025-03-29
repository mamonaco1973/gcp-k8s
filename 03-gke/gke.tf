# ====================================================================
# GKE CLUSTER: PRIMARY CONTROL PLANE CONFIGURATION
# ====================================================================
resource "google_container_cluster" "primary" {
  name     = var.gke_cluster_name            # Cluster name from input variable (e.g., "flask")
  location = var.zone                        # GCP zone (e.g., "us-central1-a")

  remove_default_node_pool = true            # Delete the useless default node pool (we'll define our own)
  initial_node_count       = 1               # Required placeholder value; has no effect when node pool is removed

  network    = google_compute_network.gke_vpc.name        # Attach cluster to custom VPC
  subnetwork = google_compute_subnetwork.gke_subnet.name  # Use custom subnet inside that VPC

  ip_allocation_policy {}                    # Enable VPC-native (alias IP) mode — a GKE best practice

  deletion_protection = false                # Allow terraform destroy to clean up this cluster (don't lock it)

  workload_identity_config {
    workload_pool = "${local.credentials.project_id}.svc.id.goog"  
    # 🔐 Enable Workload Identity to let K8s service accounts impersonate GCP service accounts
  }

  private_cluster_config {
     enable_private_nodes    = true              # ⛔ No public IPs on nodes
  }
}

# ====================================================================
# GKE NODE POOL: CUSTOM DEFINED COMPUTE WORKERS
# ====================================================================
resource "google_container_node_pool" "primary_nodes" {
  name     = "default-node-pool"                        # Clean, non-redundant node pool name
  location = var.zone                                   # Same zone as the cluster
  cluster  = google_container_cluster.primary.name      # Link this node pool to the cluster above

  node_config {
    machine_type = "e2-standard-4"                      # 💪 Choose a decent VM size for actual workloads
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"  # Full GCP access from nodes (needed for logging, monitoring, etc.)
    ]
  }

  autoscaling {
    min_node_count = 1     # Scale down to 1 node during low usage
    max_node_count = 4     # Scale up to 4 nodes under load
  }

  initial_node_count = 1   # Start with 1 node initially (autoscaler will take over after)
}

# ====================================================================
# KUBERNETES PROVIDER: CONNECTS TERRAFORM TO GKE API SERVER
# ====================================================================
provider "kubernetes" {
  host = "https://${google_container_cluster.primary.endpoint}"  
  # 🎯 Directly target the GKE cluster's Kubernetes API server

  token = data.google_client_config.default.access_token
  # 🔐 Auth to the cluster using the access token tied to your gcloud credentials

  cluster_ca_certificate = base64decode(google_container_cluster.primary.master_auth[0].cluster_ca_certificate)
  # 🧾 Ensure TLS verification by providing the cluster's CA cert
}
