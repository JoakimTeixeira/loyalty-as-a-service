#!/bin/bash

BASE_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)
cd "$BASE_DIR"

source scripts/auth/Access.sh
source scripts/terraform/utils/ExportVariables.sh

# RDS
cd terraform/RDS
terraform destroy -auto-approve
cd ../..

# Kafka
cd terraform/Kafka
terraform destroy -auto-approve
cd ../..

# Quarkus Purchase
cd terraform/Quarkus/Purchase
terraform destroy -auto-approve
cd ../../..

# Quarkus customer
cd terraform/Quarkus/customer
terraform destroy -auto-approve
cd ../../..

# Quarkus shop
cd terraform/Quarkus/shop
terraform destroy -auto-approve
cd ../../..

# Quarkus loyaltycard
cd terraform/Quarkus/loyaltycard
terraform destroy -auto-approve
cd ../../..

# Quarkus discountcoupon
cd terraform/Quarkus/discountcoupon
terraform destroy -auto-approve
cd ../../..

# Quarkus crossselling
cd terraform/Quarkus/crossselling
terraform destroy -auto-approve
cd ../../..

# Kong, Konga and Camunda
cd terraform/Kong
terraform destroy -auto-approve
cd ../..

# All Quarkus Docker Images
source scripts/terraform/utils/RemoveDockerImages.sh

# Key Pair Secrets
# Kafka Cluster depends on Key Pair Secrets, so the cluster should be destroyed before
cd terraform/Secrets
terraform destroy -auto-approve
cd ../..

# S3 Bucket
# Should be the last to be destroyed because it holds the terraform state from all the resources
cd terraform/S3
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
cd ../..

source scripts/auth/CleanAllProjects.sh
