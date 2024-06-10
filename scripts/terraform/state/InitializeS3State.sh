#!/bin/bash

# Set the base directory to the script's location
BASE_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)
cd "$BASE_DIR"

# Source required scripts
source scripts/auth/Access.sh
source scripts/terraform/utils/ExportVariables.sh

# Initialize S3 Bucket with local backend if S3 backend is not already configured
cd terraform/S3

# Check if backend.tf already contains the S3 backend configuration
S3_BACKEND_EXISTS=$(grep 'backend "s3"' backend.tf)

# If S3 backend is local, initialize it and then migrate the state to S3 bucket
if [ -z "$S3_BACKEND_EXISTS" ]; then
    echo "Configuring local backend for initial setup..."

    {
        echo "terraform {"
        echo "  backend \"local\" {"
        echo "    path = \"terraform.tfstate\""
        echo "  }"
        echo "}"
    } >backend.tf

    # Initialize and apply Terraform with local backend
    terraform init
    terraform apply -auto-approve

    echo "Migrating state to S3 backend..."

    # Update S3 backend configuration for S3 module
    {
        echo "terraform {"
        echo "  backend \"s3\" {}"
        echo "}"
    } >backend.tf

    # Migrate state from local to S3 using 'yes' to automatically confirm the migration
    echo "yes" | terraform init -backend-config=backend-config.hcl -migrate-state
    terraform apply -auto-approve

    # Remove local state files after migration
    rm terraform.tfstate
    rm terraform.tfstate.backup
else
    echo "S3 backend already configured. Initializing remote backend..."
    terraform init -backend-config=backend-config.hcl
    terraform apply -auto-approve
fi

cd ../..
