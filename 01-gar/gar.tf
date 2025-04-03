# ====================================================================
# GOOGLE ARTIFACT REGISTRY REPOSITOIES
# Stores container images used by GKE, Cloud Run, etc.
# Replaces the older Google Container Registry (GCR) with a modern, regional, secure option
# ====================================================================
resource "google_artifact_registry_repository" "flask_repo" {
  provider = google                                     # 📦 Use the authenticated Google provider

  project  = local.credentials.project_id               # 🔐 Target project ID from your decoded credentials.json
                                                        # Avoid hardcoding it like a rookie

  location = "us-central1"                              # 🧭 Regional placement — must match your GKE cluster
                                                        # Artifact Registry is **regional**, not global

  repository_id = "flask-repository"                    # 🏷️ Logical name for your Docker repo
                                                        # Shows up in the console and forms part of the image path:
                                                        #   us-central1-docker.pkg.dev/<project>/flask-repository/...

  format = "DOCKER"                                     # 📦 Set to "DOCKER" to support pushing Docker container images
                                                        # Alternatives: "MAVEN", "NPM", "PYTHON", etc.
}


resource "google_artifact_registry_repository" "games_repo" {
  provider = google                                     # 📦 Use the authenticated Google provider

  project  = local.credentials.project_id               # 🔐 Target project ID from your decoded credentials.json
                                                        # Avoid hardcoding it like a rookie

  location = "us-central1"                              # 🧭 Regional placement — must match your GKE cluster
                                                        # Artifact Registry is **regional**, not global

  repository_id = "games-repository"                    # 🏷️ Logical name for your Docker repo
                                                        # Shows up in the console and forms part of the image path:
                                                        #   us-central1-docker.pkg.dev/<project>/flask-repository/...

  format = "DOCKER"                                     # 📦 Set to "DOCKER" to support pushing Docker container images
                                                        # Alternatives: "MAVEN", "NPM", "PYTHON", etc.
}