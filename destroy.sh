export GOOGLE_APPLICATION_CREDENTIALS="$(pwd)/credentials.json"

cd "03-gke"

echo "NOTE: Destroying GKE Instance"

if [ ! -d ".terraform" ]; then
    terraform init
fi
terraform destroy -auto-approve
rm -f -r .terraform terraform*
cd ..

echo "NOTE: Destroying GAR instance."

cd "01-gar"
if [ ! -d ".terraform" ]; then
    terraform init
fi

terraform destroy -auto-approve
rm -f -r .terraform terraform*
cd ..




