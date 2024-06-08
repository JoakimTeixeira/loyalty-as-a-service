#!/bin/bash

# Get the directory of the script
BASE_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cd "$BASE_DIR"

echo "Cleaning all projects..."
echo

ACCESS_PATH="scripts/auth/Access.sh"

# Check if Access.sh exists and remove all credentials if it does
if [ -f "$ACCESS_PATH" ]; then
    sed -i "s/^aws_access_key_id=.*/aws_access_key_id=''/g" "$ACCESS_PATH"
    sed -i "s/^aws_secret_access_key=.*/aws_secret_access_key=''/g" "$ACCESS_PATH"
    sed -i "s/^aws_session_token=.*/aws_session_token=''/g" "$ACCESS_PATH"
    sed -i "s/^export TF_VAR_dockerhub_username=.*/export TF_VAR_dockerhub_username=''/g" "$ACCESS_PATH"
    sed -i "s/^export TF_VAR_dockerhub_password=.*/export TF_VAR_dockerhub_password=''/g" "$ACCESS_PATH"
else
    echo "Warning: $ACCESS_PATH not found."
fi

# Function to clean microservice configuration files
clean_microservice() {
    local service_dir=$1
    if [ -f "$service_dir/src/main/resources/application.properties" ]; then
        sed -i "s/^quarkus\.container-image\.group=.*/quarkus.container-image.group=''/g" "$service_dir/src/main/resources/application.properties"
        sed -i "s/^quarkus\.datasource\.reactive\.url=.*/quarkus.datasource.reactive.url=''/g" "$service_dir/src/main/resources/application.properties"
        sed -i "s/^kafka\.bootstrap\.servers=.*/kafka.bootstrap.servers=''/g" "$service_dir/src/main/resources/application.properties"
    else
        echo "Warning: $service_dir/src/main/resources/application.properties not found."
    fi
}

# Clean configuration files for each microservice
clean_microservice "microservices/customer"
clean_microservice "microservices/loyaltycard"
clean_microservice "microservices/Purchase"
clean_microservice "microservices/shop"

# Remove all compilation files from Terraform
find . \( -name ".terraform" -o -name ".terraform.tfstate.lock.info" -o -name "terraform.tfstate" -o -name "terraform.tfstate.backup" \) -exec rm -rf {} +

# Remove all compilation files from microservices
find . \( -name "target" \) -type d -exec rm -rf {} +

echo "All projects were cleaned!"
echo
