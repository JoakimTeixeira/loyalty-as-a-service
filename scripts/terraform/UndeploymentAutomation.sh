#!/bin/bash

BASE_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)
cd "$BASE_DIR"

source scripts/auth/Access.sh
source scripts/terraform/utils/ExportVariables.sh

TERRAFORM_STATE_FOLDER=".terraform"

# RDS
cd terraform/RDS
if [ -d "$TERRAFORM_STATE_FOLDER" ]; then
    terraform destroy -auto-approve
fi
cd ../..

# Kafka
cd terraform/Kafka
if [ -d "$TERRAFORM_STATE_FOLDER" ]; then
    terraform destroy -auto-approve
fi
cd ../..

# Quarkus purchase
cd terraform/Quarkus/purchase
if [ -d "$TERRAFORM_STATE_FOLDER" ]; then
    terraform destroy -auto-approve
fi
cd ../../..

# Quarkus customer
cd terraform/Quarkus/customer
if [ -d "$TERRAFORM_STATE_FOLDER" ]; then
    terraform destroy -auto-approve
fi
cd ../../..

# Quarkus shop
cd terraform/Quarkus/shop
if [ -d "$TERRAFORM_STATE_FOLDER" ]; then
    terraform destroy -auto-approve
fi
cd ../../..

# Quarkus loyaltycard
cd terraform/Quarkus/loyaltycard
if [ -d "$TERRAFORM_STATE_FOLDER" ]; then
    terraform destroy -auto-approve
fi
cd ../../..

# Quarkus discountcoupon
cd terraform/Quarkus/discountcoupon
if [ -d "$TERRAFORM_STATE_FOLDER" ]; then
    terraform destroy -auto-approve
fi
cd ../../..

# Quarkus crossselling
cd terraform/Quarkus/crossselling
if [ -d "$TERRAFORM_STATE_FOLDER" ]; then
    terraform destroy -auto-approve
fi
cd ../../..

# Quarkus selledproduct
cd terraform/Quarkus/selledproduct
if [ -d "$TERRAFORM_STATE_FOLDER" ]; then
    terraform destroy -auto-approve
fi
cd ../../..

# Kong, Konga and Camunda
cd terraform/Kong
if [ -d "$TERRAFORM_STATE_FOLDER" ]; then
    terraform destroy -auto-approve
fi
cd ../..

# All Quarkus Docker Images
source scripts/terraform/utils/RemoveDockerImages.sh

# Key Pair Secrets
# Kafka Cluster depends on Key Pair Secrets, so the cluster should be destroyed before
cd terraform/Secrets
if [ -d "$TERRAFORM_STATE_FOLDER" ]; then
    terraform destroy -auto-approve
fi
cd ../..

# S3 Bucket
# Should be the last to be destroyed because it holds the terraform state from all the resources
cd terraform/S3
if [ -d "$TERRAFORM_STATE_FOLDER" ]; then
    # Reset S3 bucket state to local backend
    {
        echo "terraform {"
        echo "  backend \"local\" {"
        echo "    path = \"terraform.tfstate\""
        echo "  }"
        echo "}"
    } >backend.tf
    echo yes | terraform init -migrate-state
    terraform destroy -auto-approve
fi
cd ../..

source scripts/auth/CleanProject.sh
