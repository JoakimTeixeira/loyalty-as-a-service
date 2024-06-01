#!/bin/bash

BASE_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cd "$BASE_DIR"

source scripts/auth/Access.sh

echo "Starting deployment..."
echo

# ================================================================================

# Terraform 1 - RDS
cd terraform/RDS
terraform init
terraform apply -auto-approve
esc=$'\e'
addressRDS="$(terraform state show aws_db_instance.rds_db | grep address | sed "s/address//g" | sed "s/=//g" | sed "s/\"//g" | sed "s/ //g" | sed "s/$esc\[[0-9;]*m//g")"
cd ../..

# ================================================================================

# Terraform 2 - Kafka
cd terraform/Kafka
terraform init
terraform apply -auto-approve
esc=$'\e'
# addresskafka2=$(terraform state list 'aws_instance.kafkaCluster' | xargs -I {} terraform state show {} | grep public_dns | awk '{print $3}' | tr -d '"' | paste -sd ',' -)
addresskafka="$(terraform state show 'aws_instance.kafkaCluster[0]' | grep public_dns | sed "s/public_dns//g" | sed "s/=//g" | sed "s/\"//g" | sed "s/ //g" | sed "s/$esc\[[0-9;]*m//g")"
cd ../..

# ================================================================================

# Dockerize Purchase Microservice -> changes the configuration of the DB connection, recompiling and packaging
cd microservices/Purchase/src/main/resources

# # Finds line starting with "quarkus.container-image.group=" and replaces anything after it with "$TF_VAR_dockerhub_username" variable
sed -i 's/^quarkus\.container-image\.group=.*/quarkus.container-image.group='"$TF_VAR_dockerhub_username"'/' application.properties

# # Finds line starting with "quarkus.datasource.reactive.url=" and replaces anything after it with "mysql://$addressRDS:3306/quarkus_test_all_operations"
sed -i 's/^quarkus\.datasource\.reactive\.url=.*/quarkus.datasource.reactive.url=mysql:\/\/'"$addressRDS"':3306\/quarkus_test_all_operations/' application.properties

# # Finds line starting with "kafka.bootstrap.servers=" and replaces anything after it with "$addresskafka:9092"
sed -i 's/^kafka\.bootstrap\.servers=.*/kafka.bootstrap.servers='"$addresskafka"':9092/' application.properties

# Builds the Docker image or skips if it already exists in Docker Hub
if ! curl -s -f -lSL "https://hub.docker.com/v2/repositories/${TF_VAR_dockerhub_username}/purchase/tags/1.0.0-SNAPSHOT" >/dev/null 2>&1; then
    echo
    echo "Docker image not found in Docker Hub. Building package..."
    cd ../../..
    ./mvnw clean package
    cd ../..
else
    echo
    echo "Docker image already exists in Docker Hub. Skipping build..."
    cd ../../../../..
fi

# Terraform 3 - Purchase
cd terraform/Quarkus/Purchase
terraform init
terraform apply -auto-approve
cd ../../..

# ================================================================================

# Dockerize loyaltycard Microservice -> changes the configuration of the DB connection, recompiling and packaging
cd microservices/loyaltycard/src/main/resources

# # Finds line starting with "quarkus.container-image.group=" and replaces anything after it with "$TF_VAR_dockerhub_username" variable
sed -i 's/^quarkus\.container-image\.group=.*/quarkus.container-image.group='"$TF_VAR_dockerhub_username"'/' application.properties

# # Finds line starting with "quarkus.datasource.reactive.url=" and replaces anything after it with "mysql://$addressRDS:3306/quarkus_test_all_operations"
sed -i 's/^quarkus\.datasource\.reactive\.url=.*/quarkus.datasource.reactive.url=mysql:\/\/'"$addressRDS"':3306\/quarkus_test_all_operations/' application.properties

# # Finds line starting with "kafka.bootstrap.servers=" and replaces anything after it with "$addresskafka:9092"
sed -i 's/^kafka\.bootstrap\.servers=.*/kafka.bootstrap.servers='"$addresskafka"':9092/' application.properties

# Builds the Docker image or skips if it already exists in Docker Hub
if ! curl -s -f -lSL "https://hub.docker.com/v2/repositories/${TF_VAR_dockerhub_username}/loyaltycard/tags/1.0.0-SNAPSHOT" >/dev/null 2>&1; then
    echo
    echo "Docker image not found in Docker Hub. Building package..."
    cd ../../..
    ./mvnw clean package
    cd ../..
else
    echo
    echo "Docker image already exists in Docker Hub. Skipping build..."
    cd ../../../../..
fi

# Terraform 4 - loyaltycard
cd terraform/Quarkus/loyaltycard
terraform init
terraform apply -auto-approve
cd ../../..

# ================================================================================

# Dockerize customer Microservice -> changes the configuration of the DB connection, recompiling and packaging
cd microservices/customer/src/main/resources

# # Finds line starting with "quarkus.container-image.group=" and replaces anything after it with "$TF_VAR_dockerhub_username" variable
sed -i 's/^quarkus\.container-image\.group=.*/quarkus.container-image.group='"$TF_VAR_dockerhub_username"'/' application.properties

# # Finds line starting with "quarkus.datasource.reactive.url=" and replaces anything after it with "mysql://$addressRDS:3306/quarkus_test_all_operations"
sed -i 's/^quarkus\.datasource\.reactive\.url=.*/quarkus.datasource.reactive.url=mysql:\/\/'"$addressRDS"':3306\/quarkus_test_all_operations/' application.properties

# # Finds line starting with "kafka.bootstrap.servers=" and replaces anything after it with "$addresskafka:9092"
sed -i 's/^kafka\.bootstrap\.servers=.*/kafka.bootstrap.servers='"$addresskafka"':9092/' application.properties

# Builds the Docker image or skips if it already exists in Docker Hub
if ! curl -s -f -lSL "https://hub.docker.com/v2/repositories/${TF_VAR_dockerhub_username}/customer/tags/1.0.0-SNAPSHOT" >/dev/null 2>&1; then
    echo
    echo "Docker image not found in Docker Hub. Building package..."
    cd ../../..
    ./mvnw clean package
    cd ../..
else
    echo
    echo "Docker image already exists in Docker Hub. Skipping build..."
    cd ../../../../..
fi

# Terraform 5 - customer
cd terraform/Quarkus/customer
terraform init
terraform apply -auto-approve
cd ../../..

# ================================================================================

# Dockerize shop Microservice -> changes the configuration of the DB connection, recompiling and packaging
cd microservices/shop/src/main/resources

# # Finds line starting with "quarkus.container-image.group=" and replaces anything after it with "$TF_VAR_dockerhub_username" variable
sed -i 's/^quarkus\.container-image\.group=.*/quarkus.container-image.group='"$TF_VAR_dockerhub_username"'/' application.properties

# # Finds line starting with "quarkus.datasource.reactive.url=" and replaces anything after it with "mysql://$addressRDS:3306/quarkus_test_all_operations"
sed -i 's/^quarkus\.datasource\.reactive\.url=.*/quarkus.datasource.reactive.url=mysql:\/\/'"$addressRDS"':3306\/quarkus_test_all_operations/' application.properties

# # Finds line starting with "kafka.bootstrap.servers=" and replaces anything after it with "$addresskafka:9092"
sed -i 's/^kafka\.bootstrap\.servers=.*/kafka.bootstrap.servers='"$addresskafka"':9092/' application.properties

# Builds the Docker image or skips if it already exists in Docker Hub
if ! curl -s -f -lSL "https://hub.docker.com/v2/repositories/${TF_VAR_dockerhub_username}/shop/tags/1.0.0-SNAPSHOT" >/dev/null 2>&1; then
    echo
    echo "Docker image not found in Docker Hub. Building package..."
    cd ../../..
    ./mvnw clean package
    cd ../..
else
    echo
    echo "Docker image already exists in Docker Hub. Skipping build..."
    cd ../../../../..
fi

# Terraform 6 - shop
cd terraform/Quarkus/shop
terraform init
terraform apply -auto-approve
cd ../../..

# ================================================================================

# Terraform 7 - Kong
cd terraform/Kong
terraform init
terraform apply -auto-approve
pathKong="$(terraform state show aws_instance.installKong | grep public_dns | sed "s/public_dns//g" | sed "s/=//g" | sed "s/\"//g" | sed "s/ //g" | sed "s/$esc\[[0-9;]*m//g")"
export TF_VAR_addressKong="http://${pathKong}:8001"
cd ../..

# ================================================================================

# Terraform 8 - Konga
cd terraform/Konga
terraform init
terraform apply -auto-approve
cd ../..

# ================================================================================

# Terraform 9 - Camunda
cd terraform/Camunda
terraform init
terraform apply -auto-approve
cd ../..

# ============================= Export PUBLIC_DNSs ===============================

source scripts/terraform/ExportAddresses.sh

# ============================ Setup Kong API Gateway ============================

source scripts/api/KongConfiguration.sh

# =============================== Update Bpmn Files ==============================

source scripts/bpmn/UpdateBpmn.sh

# ========================== Showing all the PUBLIC_DNSs =========================

source scripts/terraform/PrintAddresses.sh

# ================================================================================

echo "Finished deployment."
echo
