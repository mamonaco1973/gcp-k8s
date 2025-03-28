#!/bin/bash

# Get the service URL
SERVICE_URL=$(gcloud run services list --platform managed --format="value(URL)" | grep "flask-app-service")

# Check if the SERVICE_URL is empty
if [[ -z "$SERVICE_URL" || "$SERVICE_URL" == "None" ]]; then
  echo "ERROR: Service URL for cloud run is not found. Please check if the service exists and try again."
  exit 1
fi

# Wait for ingress to be ready
echo "NOTE: Waiting for the API to be reachable..."

while true; do
    HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" -X POST "$SERVICE_URL/candidate/John%20Smith")

    if [[ "$HTTP_STATUS" == "200" ]]; then
        echo "NOTE: API is now reachable."
        break
    else
        echo "WARNING: API is not yet reachable (HTTP $HTTP_STATUS). Retrying..."
        sleep 30
    fi
done

# Move to the directory and run the test script
cd ./02-docker
echo "NOTE: Testing the GCP Cloud Run Solution."
echo "NOTE: URL for GCP Cloud Run is $SERVICE_URL/gtg?details=true"
./test_candidates.py "$SERVICE_URL"

cd ..
