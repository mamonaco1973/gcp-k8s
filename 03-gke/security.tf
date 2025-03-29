# ====================================================================
# KUBERNETES SERVICE ACCOUNT (KSA)
# This is the in-cluster identity your pods will run as.
# It MUST be annotated to link it to a GCP IAM service account (GSA)
# ====================================================================
resource "kubernetes_service_account" "firestore_access" {
  metadata {
    name      = "firestore-access-sa"           # 👈 K8s service account name (used in your Pod specs)
    namespace = "default"                       # 📍 Namespace where your app lives (must match Deployment)

    annotations = {
      # 🔗 This is the magic line that links KSA to GSA for Workload Identity
      "iam.gke.io/gcp-service-account" = google_service_account.firestore_gsa.email
    }
  }

  # 🔒 Important: Don’t let this run until the cluster is actually up
  depends_on = [google_container_cluster.primary]
}

# ====================================================================
# GOOGLE SERVICE ACCOUNT (GSA)
# This is the actual IAM identity that talks to Firestore on behalf of your pod
# ====================================================================
resource "google_service_account" "firestore_gsa" {
  account_id   = "firestore-access"              # Unique ID for the service account in GCP
  display_name = "Firestore Access for GKE Pods" # Nice label for humans in the console
}

# ====================================================================
# GRANT FIRESTORE ACCESS TO THE GSA
# This gives the GSA permission to interact with Firestore
# ====================================================================
resource "google_project_iam_member" "firestore_gsa_permissions" {
  project = local.credentials.project_id                    # Your current project ID
  role    = "roles/datastore.user"                          # 🔐 Firestore user-level access (read/write docs)
  member  = "serviceAccount:${google_service_account.firestore_gsa.email}" 
  # 📛 Apply that role to the GSA we just created
}

# ====================================================================
# ALLOW KSA TO ACT AS THE GSA
# This binds the Kubernetes SA to the IAM SA with Workload Identity
# ====================================================================
resource "google_service_account_iam_member" "ksa_to_gsa_binding" {
  service_account_id = google_service_account.firestore_gsa.name
  role               = "roles/iam.workloadIdentityUser"      # 🧙 Required for Workload Identity
  member             = "serviceAccount:${local.credentials.project_id}.svc.id.goog[default/firestore-access-sa]"
  # 🪪 Format: <project>.svc.id.goog[<namespace>/<ksa-name>]
  # This tells GCP: "Let this KSA impersonate that GSA"
}
