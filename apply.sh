#!/bin/bash

./check_env.sh
if [ $? -ne 0 ]; then
  echo "ERROR: Environment check failed. Exiting."
  exit 1
fi

export GOOGLE_APPLICATION_CREDENTIALS="$(pwd)/credentials.json"

# Navigate to the 01-gar directory
cd "01-gar" 
echo "NOTE: Building GAR Instance."

if [ ! -d ".terraform" ]; then
    terraform init
fi
terraform apply -auto-approve

# Return to the parent directory
cd ..

# Navigate to the 02-docker directory

cd "02-docker"
echo "NOTE: Building flask container with Docker."

gcloud auth configure-docker us-central1-docker.pkg.dev -q 
project_id=$(jq -r '.project_id' "../credentials.json")

GCR_IMAGE=us-central1-docker.pkg.dev/$project_id/games-repository/tetris:rc1
cd tetris
docker build -t $GCR_IMAGE . --push
cd ..

GCR_IMAGE=us-central1-docker.pkg.dev/$project_id/games-repository/frogger:rc1
cd frogger
docker build -t $GCR_IMAGE . --push
cd ..

GCR_IMAGE=us-central1-docker.pkg.dev/$project_id/games-repository/breakout:rc1
cd breakout
docker build -t $GCR_IMAGE . --push
cd ..

GCR_IMAGE=us-central1-docker.pkg.dev/$project_id/flask-repository/flask-app:flask-app-rc1
cd flask-app
docker build -t $GCR_IMAGE . --push
cd ..

cd ..

# Navigate to the 03-gke directory
cd 03-gke
echo "NOTE: Deploying GKE Instance"

if [ ! -d ".terraform" ]; then
    terraform init
fi
terraform apply -auto-approve

# Replace ${GCR_NAME} in the deployment template

sed "s|\$IMAGE|$GCR_IMAGE|g" yaml/flask-app.yaml.tmpl > ../flask-app.yaml || {
    echo "ERROR: Failed to generate Kubernetes deployment file. Exiting."
    exit 1
}


# Return to the parent directory
cd ..

export USE_GKE_GCLOUD_AUTH_PLUGIN=True
gcloud container clusters get-credentials flask-gke \
  --zone us-central1-a \
  --project $project_id

kubectl get nodes
kubectl apply -f flask-app.yaml

# Execute the validation script

./validate.sh


