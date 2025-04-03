#!/bin/bash
# ---------------------------------------------------------
# Script to Validate GKE Ingress Endpoint + API Readiness
# ---------------------------------------------------------

MAX_RETRIES=5       # Maximum number of times to poll for the Ingress IP
RETRY_DELAY=30      # Delay between retries in seconds
ATTEMPT=1           # Counter for the current retry attempt

# ---------------------------------------------------------
# STEP 1: Wait for Ingress External IP from Kubernetes
# ---------------------------------------------------------
while [ $ATTEMPT -le $MAX_RETRIES ]; do

  # Try to retrieve the external IP from the ingress
  INGRESS_IP=$(kubectl get ingress flask-app-ingress -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

  if [ -n "$INGRESS_IP" ]; then
    echo "NOTE: Ingress IP retrieved: $INGRESS_IP"
    break
  fi

  echo "WARNING: Ingress IP not yet available. Retrying in $RETRY_DELAY seconds..."
  sleep $RETRY_DELAY
  ((ATTEMPT++))
done

# Final validation after exhausting retries
if [ -z "$INGRESS_IP" ]; then
  echo "ERROR: Failed to retrieve the Ingress IP address after $MAX_RETRIES attempts."
  exit 1
fi

# ---------------------------------------------------------
# STEP 2: Wait Until Flask API Is Ready and Responding (HTTP 200)
# ---------------------------------------------------------
while true; do
    HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" -X POST "http://$INGRESS_IP/flask-app/api/candidate/John%20Smith")

    if [[ "$HTTP_STATUS" == "200" ]]; then
        echo "NOTE: API is now reachable via Ingress."
        break
    else
        echo "WARNING: API is not yet reachable (HTTP $HTTP_STATUS). Retrying..."
        sleep 30
    fi
done

# ---------------------------------------------------------
# STEP 3: Run End-to-End Test Script Against the Flask API
# ---------------------------------------------------------

cd ./02-docker

SERVICE_URL="http://$INGRESS_IP/flask-app/api"

echo "NOTE: Testing the GKE + Ingress deployment."
echo "NOTE: URL for GKE Deployment is $SERVICE_URL/gtg?details=true"

./test_candidates.py "$SERVICE_URL"

cd ..
