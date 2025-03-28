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
GCR_IMAGE=us-central1-docker.pkg.dev/$project_id/flask-repository/flask-app:flask-app-rc1
docker build -t $GCR_IMAGE . --push
cd ..

# Navigate to the 03-cloudrun directory
cd 03-cloudrun
echo "NOTE: Deploying flask container with cloud run."

if [ ! -d ".terraform" ]; then
    terraform init
fi
terraform apply -auto-approve

# Return to the parent directory
cd ..

# Execute the validation script

./validate.sh


