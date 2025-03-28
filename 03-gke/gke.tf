resource "google_container_cluster" "primary" {
  name     = var.gke_cluster_name
  location = var.zone

  remove_default_node_pool = true
  initial_node_count       = 1

  network    = google_compute_network.gke_vpc.name
  subnetwork = google_compute_subnetwork.gke_subnet.name

  ip_allocation_policy {}
  deletion_protection = false
}


resource "google_container_node_pool" "primary_nodes" {
  name     = "${var.gke_cluster_name}-node-pool"
  location = var.zone
  cluster  = google_container_cluster.primary.name

  node_config {
    machine_type = "e2-medium"
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
