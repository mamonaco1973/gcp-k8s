#!/bin/bash
# Exit immediately if a command exits with a non-zero status (optional safety).
# set -e  

# Run the environment check script to ensure required files/configs are present.
./check_env.sh

# Check if the previous command (check_env.sh) exited with a non-zero status (i.e., failed).
if [ $? -ne 0 ]; then
  echo "ERROR: Environment check failed. Exiting."
  exit 1  # Exit the script to prevent any further execution.
fi

# Set the environment variable that points to the Google Cloud credentials file.
export GOOGLE_APPLICATION_CREDENTIALS="$(pwd)/credentials.json"

######################
# STAGE 1: GAR Setup #
######################

# Move into the first directory where the Google Artifact Registry (GAR) setup lives.
cd "01-gar"
echo "NOTE: Building GAR Instance."

# Initialize Terraform only if the .terraform directory does not exist.
# This prevents redundant initialization in repeated runs.
if [ ! -d ".terraform" ]; then
    terraform init
fi

# Apply the Terraform configuration non-interactively.
terraform apply -auto-approve

# Return to the root/parent directory after GAR setup is complete.
cd ..

###################################
# STAGE 2: Docker Image Building  #
###################################

# Move into the Docker setup directory where all container builds occur.
cd "02-docker"
echo "NOTE: Building flask container with Docker."

# Authenticate Docker with Google Artifact Registry for the specified region.
gcloud auth configure-docker us-central1-docker.pkg.dev -q 

# Extract the GCP project ID from the credentials JSON file.
project_id=$(jq -r '.project_id' "../credentials.json")

# --- Build and Push: Tetris Container ---
GCR_IMAGE=us-central1-docker.pkg.dev/$project_id/games-repository/tetris:rc1
cd tetris
docker build -t $GCR_IMAGE . --push  # Build and push image in one step using BuildKit.
cd ..

# --- Build and Push: Frogger Container ---
GCR_IMAGE=us-central1-docker.pkg.dev/$project_id/games-repository/frogger:rc1
cd frogger
docker build -t $GCR_IMAGE . --push
cd ..

# --- Build and Push: Breakout Container ---
GCR_IMAGE=us-central1-docker.pkg.dev/$project_id/games-repository/breakout:rc1
cd breakout
docker build -t $GCR_IMAGE . --push
cd ..

# --- Build and Push: Flask App Container ---
GCR_IMAGE=us-central1-docker.pkg.dev/$project_id/flask-repository/flask-app:flask-app-rc1
cd flask-app
docker build -t $GCR_IMAGE . --push
cd ..

# Return to the root directory after all images are built and pushed.
cd ..

###############################
# STAGE 3: GKE Deployment     #
###############################

# Move into the Terraform GKE configuration directory.
cd 03-gke
echo "NOTE: Deploying GKE Instance"

# Initialize Terraform for GKE setup if it hasn't been initialized already.
if [ ! -d ".terraform" ]; then
    terraform init
fi

# Apply the GKE Terraform infrastructure with no manual approval prompts.
terraform apply -auto-approve

# Generate final Kubernetes deployment YAML for Flask App by injecting project_id.
# If it fails, exit the script.
sed "s|\$project_id|$project_id|g" yaml/flask-app.yaml.tmpl > ../flask-app.yaml || {
    echo "ERROR: Failed to generate Kubernetes deployment file. Exiting."
    exit 1
}

# Generate final Kubernetes deployment YAML for game services (Tetris/Frogger/Breakout).
sed "s|\$project_id|$project_id|g" yaml/games.yaml.tmpl > ../games.yaml || {
    echo "ERROR: Failed to generate Kubernetes deployment file. Exiting."
    exit 1
}

# Return to the root directory to continue with Kubernetes deployment.
cd ..

###########################################
# STAGE 4: Kubernetes Workload Deployment #
###########################################

# Enable GKE auth plugin compatibility for newer kubectl versions.
export USE_GKE_GCLOUD_AUTH_PLUGIN=True

# Fetch Kubernetes credentials from the newly created GKE cluster to configure kubectl.
gcloud container clusters get-credentials flask-gke \
  --zone us-central1-a \
  --project $project_id

# Display current nodes in the cluster to verify connectivity.
kubectl get nodes

# Deploy the Flask app and game services to the GKE cluster.
kubectl apply -f flask-app.yaml
kubectl apply -f games.yaml

##############################
# STAGE 5: Post-deployment   #
##############################

# Execute the validation script to test that the deployment is working as expected.
./validate.sh
