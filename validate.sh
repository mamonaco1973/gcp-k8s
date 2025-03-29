#!/bin/bash
# ---------------------------------------------------------
# Script to Validate AKS Service Endpoint + API Readiness
# ---------------------------------------------------------

MAX_RETRIES=5       # Maximum number of times to poll for the LoadBalancer IP
RETRY_DELAY=30      # Delay between retries in seconds
ATTEMPT=1           # Counter for the current retry attempt

# ---------------------------------------------------------
# STEP 1: Wait for LoadBalancer External IP from Kubernetes
# ---------------------------------------------------------
while [ $ATTEMPT -le $MAX_RETRIES ]; do

  # Attempt to retrieve the external IP of the Kubernetes service
  SERVICE_IP=$(kubectl get service flask-app-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

  if [ -n "$SERVICE_IP" ]; then
    # IP is available, break out of retry loop
    echo "NOTE: Service IP retrieved: $SERVICE_IP"
    break
  fi

  # IP not yet assigned — typically means LoadBalancer provisioning isn't done
  echo "WARNING: Failed to retrieve service IP. Retrying in $RETRY_DELAY seconds..."
  sleep $RETRY_DELAY
  ((ATTEMPT++))
done

# Final validation after exhausting retries
if [ -z "$SERVICE_IP" ]; then
  echo "ERROR: Failed to retrieve the service IP address after $MAX_RETRIES attempts."
  exit 1
fi

# ---------------------------------------------------------
# STEP 2: Wait Until Flask API Is Ready and Responding (HTTP 200)
# ---------------------------------------------------------
while true; do
    # Perform a POST request to the /candidate/<name> endpoint
    HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" -X POST "http://$SERVICE_IP/candidate/John%20Smith")

    if [[ "$HTTP_STATUS" == "200" ]]; then
        echo "NOTE: API is now reachable."  # App is healthy and accepting traffic
        break
    else
        echo "WARNING: API is not yet reachable (HTTP $HTTP_STATUS). Retrying..." 
        sleep 30
    fi
done

# ---------------------------------------------------------
# STEP 3: Run End-to-End Test Script Against the Flask API
# ---------------------------------------------------------

cd ./02-docker  # Navigate to the directory containing the test script

SERVICE_URL="http://$SERVICE_IP"  # Base URL for the Flask service

echo "NOTE: Testing the AKS Solution."
echo "NOTE: URL for AKS Deployment is $SERVICE_URL/gtg?details=true"

# Call the Python test script with the resolved service IP
./test_candidates.py "$SERVICE_URL"

cd ..  # Return to root directory
