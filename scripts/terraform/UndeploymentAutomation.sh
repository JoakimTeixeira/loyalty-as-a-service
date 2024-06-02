#!/bin/bash

BASE_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")")
cd "$BASE_DIR"

source scripts/auth/Access.sh

# Terraform 1 - RDS
cd terraform/RDS
terraform destroy -auto-approve
cd ../..

# Terraform 2 - Kafka
cd terraform/Kafka
terraform destroy -auto-approve
cd ../..

# Terraform 3 - Quarkus Purchase
cd terraform/Quarkus/Purchase
terraform destroy -auto-approve
cd ../../..

# Terraform 4 - Quarkus customer
cd terraform/Quarkus/customer
terraform destroy -auto-approve
cd ../../..

# Terraform 5 - Quarkus shop
cd terraform/Quarkus/shop
terraform destroy -auto-approve
cd ../../..

# Terraform 6 - Quarkus loyaltycard
cd terraform/Quarkus/loyaltycard
terraform destroy -auto-approve
cd ../../..

# Terraform 7 - Quarkus discountcoupon
cd terraform/Quarkus/discountcoupon
terraform destroy -auto-approve
cd ../../..

# Terraform 8 - Kong
cd terraform/Kong
terraform destroy -auto-approve
cd ../..

# Terraform 9 - Konga
cd terraform/Konga
terraform destroy -auto-approve
cd ../..

# Terraform 10 - Camunda
cd terraform/Camunda
terraform destroy -auto-approve
cd ../..
