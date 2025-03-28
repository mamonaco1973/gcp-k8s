#!/bin/bash

echo "NOTE: Validating credentials.json and test the gcloud command"

# Check if the file "./credentials.json" exists
if [[ ! -f "./credentials.json" ]]; then
  echo "ERROR: The file './credentials.json' does not exist." >&2
  exit 1
fi

gcloud auth activate-service-account --key-file="./credentials.json"

# Extract the project_id using jq
project_id=$(jq -r '.project_id' "./credentials.json")

echo "NOTE: Enabling APIs needed for build."

gcloud config set project $project_id  
gcloud services enable compute.googleapis.com
gcloud services enable firestore.googleapis.com
gcloud services enable cloudresourcemanager.googleapis.com
gcloud services enable storage.googleapis.com
gcloud services enable apigateway.googleapis.com
gcloud services enable servicemanagement.googleapis.com
gcloud services enable servicecontrol.googleapis.com
gcloud services enable cloudfunctions.googleapis.com
gcloud services enable logging.googleapis.com
gcloud services enable run.googleapis.com
gcloud services enable artifactregistry.googleapis.com
gcloud services enable pubsub.googleapis.com
gcloud services enable cloudbuild.googleapis.com
gcloud services enable iam.googleapis.com

gcloud firestore databases create --location=us-central1 --type=firestore-native > /dev/null 2> /dev/null
