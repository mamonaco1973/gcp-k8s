# ====================================================================
# VPC NETWORK FOR GKE CLUSTER
# ====================================================================
resource "google_compute_network" "gke_vpc" {
  name                    = "gke-vpc"            # Short and readable name for the custom VPC
  auto_create_subnetworks = false                # 🔥 Critical: disables default "one-subnet-per-region" mess
                                                  # We want full control, not Google's spaghetti defaults
}

# ====================================================================
# CUSTOM SUBNET FOR GKE CLUSTER
# ====================================================================
resource "google_compute_subnetwork" "gke_subnet" {
  name          = "gke-subnet"                   # Friendly name for the subnet
  ip_cidr_range = "10.20.0.0/16"                 # 📦 CIDR block for pod IPs, services, etc. — large enough to scale
  region        = var.region                     # Region must match your cluster (e.g., "us-central1")
  network       = google_compute_network.gke_vpc.id  # 🔗 Tie this subnet to the VPC above
}

resource "google_compute_router" "nat_router" {
  name    = "gke-nat-router"
  network = google_compute_network.gke_vpc.name
  region  = var.region
}

resource "google_compute_router_nat" "nat_config" {
  name                               = "gke-nat"
  router                             = google_compute_router.nat_router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}
