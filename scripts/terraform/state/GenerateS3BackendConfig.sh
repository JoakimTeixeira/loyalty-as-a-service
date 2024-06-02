#!/bin/bash

# Set the base directory to the script's location
BASE_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)
cd "$BASE_DIR"

# Source required scripts
source scripts/auth/Access.sh
source scripts/terraform/utils/ExportVariables.sh

# Function to create backend-config.hcl file
create_backend_config() {
    local terraform_folder=$1
    local s3_state_path=$2

    # Check if the Terraform directory exists
    if [ -d "$terraform_folder" ]; then
        cd "$terraform_folder" || {
            echo "Failed to change to Terraform directory: $terraform_folder"
        }

        # Create or overwrite backend-config.hcl file
        {
            echo "bucket         = \"${S3_BUCKET_NAME}\""
            echo "key            = \"${s3_state_path}/terraform.tfstate\""
            echo "region         = \"${AWS_REGION}\""
            echo "dynamodb_table = \"${DYNAMODB_TABLE_NAME}\""
        } >backend-config.hcl

        # Return to the previous directory
        cd - >/dev/null || {
            echo "Failed to return to previous directory"
        }
    else
        echo "Directory does not exist: $terraform_folder"
    fi
}

# Array of Terraform module directories and their S3 state paths
terraform_modules=(
    "terraform/S3:s3"
    "terraform/Secrets:secrets"
    "terraform/RDS:rds"
    "terraform/Kafka:kafka"
    "terraform/Quarkus/purchase:quarkus/purchase"
    "terraform/Quarkus/customer:quarkus/customer"
    "terraform/Quarkus/shop:quarkus/shop"
    "terraform/Quarkus/loyaltycard:quarkus/loyaltycard"
    "terraform/Quarkus/discountcoupon:quarkus/discountcoupon"
    "terraform/Quarkus/crossselling:quarkus/crossselling"
    "terraform/Quarkus/selledproduct:quarkus/selledproduct"
    "terraform/Kong:kongKongaCamunda"
)

# Loop through the Terraform modules and create backend-config.hcl
for module in "${terraform_modules[@]}"; do
    IFS=":" read -r terraform_folder s3_state_path <<<"$module"
    create_backend_config "$terraform_folder" "$s3_state_path"
done

echo "Backend configuration files have been created."
