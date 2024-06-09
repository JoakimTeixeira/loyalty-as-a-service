#!/bin/bash

BASE_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")")
cd "$BASE_DIR"

source scripts/auth/Access.sh

# Key Pair Secrets
cd terraform/Secrets
terraform destroy -auto-approve
cd ../..

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
