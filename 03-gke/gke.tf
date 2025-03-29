resource "google_container_cluster" "primary" {
  name     = var.gke_cluster_name
  location = var.zone

  remove_default_node_pool = true
  initial_node_count       = 1

  network    = google_compute_network.gke_vpc.name
  subnetwork = google_compute_subnetwork.gke_subnet.name

  ip_allocation_policy {}
  deletion_protection = false

  workload_identity_config {
     workload_pool = "${local.credentials.project_id}.svc.id.goog"
  }

}


resource "google_container_node_pool" "primary_nodes" {
  name     = "default-node-pool"
  location = var.zone
  cluster  = google_container_cluster.primary.name

  node_config {
    machine_type = "e2-standard-4"
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }

  autoscaling {
    min_node_count = 1
    max_node_count = 4
  }

  initial_node_count = 1
}

resource "kubernetes_service_account" "firestore_access" {
  metadata {
    name      = "firestore-access-sa"
    namespace = "default"
    annotations = {
      "iam.gke.io/gcp-service-account" = google_service_account.firestore_gsa.email
    }
  }

  depends_on = [google_container_cluster.primary]
}

provider "kubernetes" {
  host                   = "https://${google_container_cluster.primary.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(google_container_cluster.primary.master_auth[0].cluster_ca_certificate)
}

resource "google_service_account" "firestore_gsa" {
  account_id   = "firestore-access"
  display_name = "Firestore Access for GKE Pods"
}


resource "google_project_iam_member" "firestore_gsa_permissions" {
  project = local.credentials.project_id
  role    = "roles/datastore.user"
  member  = "serviceAccount:${google_service_account.firestore_gsa.email}"
}

resource "google_service_account_iam_member" "ksa_to_gsa_binding" {
  service_account_id = google_service_account.firestore_gsa.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${local.credentials.project_id}.svc.id.goog[default/firestore-access-sa]"
}

