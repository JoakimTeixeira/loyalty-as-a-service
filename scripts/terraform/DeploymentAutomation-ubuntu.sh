#!/bin/bash

BASE_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)
cd "$BASE_DIR"

source scripts/auth/Access.sh
source scripts/terraform/utils/ExportVariables.sh

echo "Starting deployment..."
echo

# ================================================================================

# S3 Bucket

# Create S3 Bucket, save it's state in his own bucket and generate the backend-config.hcl files
source scripts/terraform/state/GenerateS3BackendConfig.sh
source scripts/terraform/state/InitializeS3State.sh

# ================================================================================

# Key Pair Secrets
cd terraform/Secrets
terraform init -backend-config=backend-config.hcl
terraform apply -auto-approve
cd ../..

# ================================================================================

# RDS
cd terraform/RDS
terraform init -backend-config=backend-config.hcl
terraform apply -auto-approve

addressesRDS=($(terraform state list 'aws_db_instance.rds_db' | xargs -I {} terraform state show {} | grep address | awk '{print $3}' | tr -d '"'))

if [ ${#addressesRDS[@]} -eq 0 ]; then
    echo
    echo "No RDS instances found."
    echo
else
    echo
    echo "Number of RDS instances found: ${#addressesRDS[@]}"
    echo
fi

cd ../..

# ================================================================================

# Kafka
cd terraform/Kafka
terraform init -backend-config=backend-config.hcl
terraform apply -auto-approve
esc=$'\e'
# addresskafka2=$(terraform state list 'aws_instance.kafkaCluster' | xargs -I {} terraform state show {} | grep public_dns | awk '{print $3}' | tr -d '"' | paste -sd ',' -)
addresskafka="$(terraform state show 'aws_instance.kafkaCluster[0]' | grep public_dns | sed "s/public_dns//g" | sed "s/=//g" | sed "s/\"//g" | sed "s/ //g" | sed "s/$esc\[[0-9;]*m//g")"
cd ../..

# ================================================================================

# Microservices

# Create and provision microservices
echo
echo "Dockerizing and provisioning microservices..."
echo

# Function to dockerize and provision a microservice
dockerize_and_provision() {
    local microservice=$1
    local index=$2

    # Check if the Docker image already exists locally
    IMAGE_EXISTS=$(docker images -q "${DOCKERHUB_USERNAME}/${microservice}:1.0.0-SNAPSHOT")

    if [ ! -z "$IMAGE_EXISTS" ]; then
        echo "Docker image already exists locally for ${microservice}. Skipping..."
    else
        # Dockerize Microservice -> changes the configuration of the DB connection, recompiling and packaging the jar
        cd microservices/${microservice}/src/main/resources

        # Finds line starting with "quarkus.datasource.username=" and replaces anything after it with "$DB_USERNAME"
        sed -i 's|^quarkus\.datasource\.username=.*|quarkus.datasource.username='"$DB_USERNAME"'|' application.properties

        # Finds line starting with "quarkus.datasource.password=" and replaces anything after it with "$DB_PASSWORD"
        sed -i 's|^quarkus\.datasource\.password=.*|quarkus.datasource.password='"$DB_PASSWORD"'|' application.properties

        # Finds line starting with "quarkus.container-image.group=" and replaces anything after it with "$DOCKERHUB_USERNAME" variable
        sed -i 's/^quarkus\.container-image\.group=.*/quarkus.container-image.group='"$DOCKERHUB_USERNAME"'/' application.properties

        # Get the address of the RDS instance
        if [ $index -le ${#addressesRDS} ]; then
            addressRDS="${addressesRDS[$index]}"
        else
            # If there are more microservices than RDS instances, choose one RDS instance at random
            # Note: Ensure the random index is within the valid range (0 to number of elements in addressesRDS)
            random_index=$(shuf -i 0-$((${#addressesRDS[@]} - 1)) -n 1)
            addressRDS="${addressesRDS[$random_index]}"
        fi

        # Finds line starting with "quarkus.datasource.reactive.url=" and replaces anything after it with "mysql://$addressRDS:3306/$DB_NAME"
        sed -i 's|^quarkus\.datasource\.reactive\.url=.*|quarkus.datasource.reactive.url=mysql://'"$addressRDS"':3306/'"$DB_NAME"'|' application.properties

        # Finds line starting with "kafka.bootstrap.servers=" and replaces anything after it with "$addresskafka:9092"
        sed -i 's/^kafka\.bootstrap\.servers=.*/kafka.bootstrap.servers='"$addresskafka"':9092/' application.properties

        cd ../../..
        ./mvnw clean package
        cd ../..

        # Get the new Docker image hash
        DOCKER_IMAGE_NAME="${DOCKERHUB_USERNAME}/${microservice}:1.0.0-SNAPSHOT"
        NEW_IMAGE_HASH=$(docker inspect --format='{{index .RepoDigests 0}}' "$DOCKER_IMAGE_NAME" 2>/dev/null | awk -F'@' '{print $2}')

        if [ -z "$NEW_IMAGE_HASH" ]; then
            echo "Failed to get the new Docker image hash for ${microservice}. Exiting..."
        else
            # Updates variable if the docker image hash has changed
            export TF_VAR_dockerhub_image_hash="$NEW_IMAGE_HASH"

            # Provision the microservice with Terraform
            cd terraform/Quarkus/${microservice}
            terraform init -backend-config=backend-config.hcl
            terraform apply -auto-approve
            cd ../../..
        fi
    fi
}

# Determine the shell type and set zsh to 0-based indexing like the bash shell
if [ -n "$ZSH_VERSION" ]; then
    setopt KSH_ARRAYS
fi

services=("purchase" "customer" "shop" "loyaltycard" "discountcoupon" "crossselling")

# Loop through the list of microservices and provision them
for ((index = 0; index < ${#services[@]}; index++)); do
    dockerize_and_provision "${services[$index]}" $index
done

# Restore zsh to 1-based indexing
if [ "$shell" = "zsh" ]; then
    unsetopt KSH_ARRAYS
fi

# ================================================================================

# Kong, Konga and Camunda
cd terraform/Kong
terraform init -backend-config=backend-config.hcl
terraform apply -auto-approve
cd ../..

# ============================= Export PUBLIC_DNSs ===============================

source scripts/terraform/utils/ExportAddresses.sh

# ============================ Setup Kong API Gateway ============================

# Wait for Kong to be ready
while ! curl -s "${pathKongKongaCamunda}:8001" >/dev/null; do
    echo "Waiting for Kong Admin API..."
    sleep 30
done

echo "Starting Kong services and routes configuration..."
echo

source scripts/api/KongConfiguration.sh

# =============================== Update Bpmn Files ==============================

source scripts/bpmn/UpdateBpmn.sh

# =========================== Update Postman Tests File ==========================

source scripts/bpmn/UpdatePostman.sh

# ========================== Showing all the PUBLIC_DNSs =========================

source scripts/terraform/utils/PrintAddresses.sh

# ================================================================================

echo "Finished deployment"
echo
