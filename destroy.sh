# Set the environment variable to use the Google Cloud credentials located in the current directory.
# This ensures all gcloud/terraform operations authenticate properly.
export GOOGLE_APPLICATION_CREDENTIALS="$(pwd)/credentials.json"

#######################################
# STAGE 1: CLEAN UP KUBERNETES DEPLOY #
#######################################

# Remove Flask app deployment from the GKE cluster.
# This deletes all Kubernetes resources (Deployment, Service, etc.) defined in the manifest.
kubectl delete -f flask-app.yaml

# Remove game services deployment (e.g., Tetris, Frogger, Breakout) from the GKE cluster.
kubectl delete -f games.yaml

##################################
# STAGE 2: DESTROY GKE INSTANCE  #
##################################

# Navigate into the directory where GKE infrastructure is managed with Terraform.
cd "03-gke"

echo "NOTE: Destroying GKE Instance"

# Initialize Terraform backend/config only if not already initialized.
# Necessary before any `terraform destroy` command.
if [ ! -d ".terraform" ]; then
    terraform init
fi

# Destroy all resources defined in the Terraform configuration without prompting for approval.
# This will delete the GKE cluster and associated network/infrastructure.
terraform destroy -auto-approve

# Clean up local Terraform working directory:
# - `.terraform/`: stores backend and provider data.
# - `terraform*`: removes generated plan/output files.
rm -f -r .terraform terraform*

# Return to the root directory after GKE destruction.
cd ..

#####################################
# STAGE 3: DESTROY GAR INFRASTRUCTURE #
#####################################

echo "NOTE: Destroying GAR instance."

# Navigate into the directory where Google Artifact Registry (GAR) infrastructure is defined.
cd "01-gar"

# Initialize Terraform if necessary before destruction.
if [ ! -d ".terraform" ]; then
    terraform init
fi

# Destroy the GAR Terraform-managed resources (e.g., repositories).
terraform destroy -auto-approve

# Remove Terraform working files and directories to ensure clean re-runs.
rm -f -r .terraform terraform*

# Return to the root directory after destroying GAR resources.
cd ..
