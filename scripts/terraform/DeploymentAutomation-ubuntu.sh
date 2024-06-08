#!/bin/bash

BASE_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cd "$BASE_DIR"

source scripts/auth/Access.sh
source scripts/terraform/ExportVariables.sh

echo "Starting deployment..."
echo

# ================================================================================

# S3 Bucket
# Should be the first to be created because holds the terraform state from all the resources
cd terraform/S3
terraform init
terraform apply -auto-approve
cd ../..

# ================================================================================

# Key Pair Secrets
cd terraform/Secrets
terraform init \
    -backend-config="bucket=${TF_VAR_s3_bucket_name}" \
    -backend-config="key=secrets/terraform.tfstate" \
    -backend-config="region=${TF_VAR_aws_region}" \
    -backend-config="dynamodb_table=${TF_VAR_dynamodb_table_name}" \
    -backend-config="encrypt=true"
terraform apply -auto-approve
cd ../..

# ================================================================================

# RDS
cd terraform/RDS
terraform init \
    -backend-config="bucket=${TF_VAR_s3_bucket_name}" \
    -backend-config="key=rds/terraform.tfstate" \
    -backend-config="region=${TF_VAR_aws_region}" \
    -backend-config="dynamodb_table=${TF_VAR_dynamodb_table_name}" \
    -backend-config="encrypt=true"
terraform apply -auto-approve
esc=$'\e'
addressRDS="$(terraform state show aws_db_instance.rds_db | grep address | sed "s/address//g" | sed "s/=//g" | sed "s/\"//g" | sed "s/ //g" | sed "s/$esc\[[0-9;]*m//g")"
cd ../..

# ================================================================================

# Kafka
cd terraform/Kafka
terraform init \
    -backend-config="bucket=${TF_VAR_s3_bucket_name}" \
    -backend-config="key=kafka/terraform.tfstate" \
    -backend-config="region=${TF_VAR_aws_region}" \
    -backend-config="dynamodb_table=${TF_VAR_dynamodb_table_name}" \
    -backend-config="encrypt=true"
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

cd ../../..
./mvnw clean package
cd ../..

# Purchase
cd terraform/Quarkus/Purchase
terraform init \
    -backend-config="bucket=${TF_VAR_s3_bucket_name}" \
    -backend-config="key=quarkus/purchase/terraform.tfstate" \
    -backend-config="region=${TF_VAR_aws_region}" \
    -backend-config="dynamodb_table=${TF_VAR_dynamodb_table_name}" \
    -backend-config="encrypt=true"
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

cd ../../..
./mvnw clean package
cd ../..

# loyaltycard
cd terraform/Quarkus/loyaltycard
terraform init \
    -backend-config="bucket=${TF_VAR_s3_bucket_name}" \
    -backend-config="key=quarkus/loyaltycard/terraform.tfstate" \
    -backend-config="region=${TF_VAR_aws_region}" \
    -backend-config="dynamodb_table=${TF_VAR_dynamodb_table_name}" \
    -backend-config="encrypt=true"
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

cd ../../..
./mvnw clean package
cd ../..

# customer
cd terraform/Quarkus/customer
terraform init \
    -backend-config="bucket=${TF_VAR_s3_bucket_name}" \
    -backend-config="key=quarkus/customer/terraform.tfstate" \
    -backend-config="region=${TF_VAR_aws_region}" \
    -backend-config="dynamodb_table=${TF_VAR_dynamodb_table_name}" \
    -backend-config="encrypt=true"
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

cd ../../..
./mvnw clean package
cd ../..

# shop
cd terraform/Quarkus/shop
terraform init \
    -backend-config="bucket=${TF_VAR_s3_bucket_name}" \
    -backend-config="key=quarkus/shop/terraform.tfstate" \
    -backend-config="region=${TF_VAR_aws_region}" \
    -backend-config="dynamodb_table=${TF_VAR_dynamodb_table_name}" \
    -backend-config="encrypt=true"
terraform apply -auto-approve
cd ../../..

# ================================================================================

# Dockerize discountcoupon Microservice -> changes the configuration of the DB connection, recompiling and packaging
cd microservices/discountcoupon/src/main/resources

# # Finds line starting with "quarkus.container-image.group=" and replaces anything after it with "$TF_VAR_dockerhub_username" variable
sed -i 's/^quarkus\.container-image\.group=.*/quarkus.container-image.group='"$TF_VAR_dockerhub_username"'/' application.properties

# # Finds line starting with "quarkus.datasource.reactive.url=" and replaces anything after it with "mysql://$addressRDS:3306/quarkus_test_all_operations"
sed -i 's/^quarkus\.datasource\.reactive\.url=.*/quarkus.datasource.reactive.url=mysql:\/\/'"$addressRDS"':3306\/quarkus_test_all_operations/' application.properties

# # Finds line starting with "kafka.bootstrap.servers=" and replaces anything after it with "$addresskafka:9092"
sed -i 's/^kafka\.bootstrap\.servers=.*/kafka.bootstrap.servers='"$addresskafka"':9092/' application.properties

cd ../../..
./mvnw clean package
cd ../..
e

# discountcoupon
cd terraform/Quarkus/discountcoupon
terraform init \
    -backend-config="bucket=${TF_VAR_s3_bucket_name}" \
    -backend-config="key=quarkus/discountcoupon/terraform.tfstate" \
    -backend-config="region=${TF_VAR_aws_region}" \
    -backend-config="dynamodb_table=${TF_VAR_dynamodb_table_name}" \
    -backend-config="encrypt=true"
terraform apply -auto-approve
cd ../../..

# ================================================================================

# Dockerize crossselling Microservice -> changes the configuration of the DB connection, recompiling and packaging
cd microservices/crossselling/src/main/resources

# # Finds line starting with "quarkus.container-image.group=" and replaces anything after it with "$TF_VAR_dockerhub_username" variable
sed -i 's/^quarkus\.container-image\.group=.*/quarkus.container-image.group='"$TF_VAR_dockerhub_username"'/' application.properties

# # Finds line starting with "quarkus.datasource.reactive.url=" and replaces anything after it with "mysql://$addressRDS:3306/quarkus_test_all_operations"
sed -i 's/^quarkus\.datasource\.reactive\.url=.*/quarkus.datasource.reactive.url=mysql:\/\/'"$addressRDS"':3306\/quarkus_test_all_operations/' application.properties

# # Finds line starting with "kafka.bootstrap.servers=" and replaces anything after it with "$addresskafka:9092"
sed -i 's/^kafka\.bootstrap\.servers=.*/kafka.bootstrap.servers='"$addresskafka"':9092/' application.properties

cd ../../..
./mvnw clean package
cd ../..

# crossselling
cd terraform/Quarkus/crossselling
terraform init \
    -backend-config="bucket=${TF_VAR_s3_bucket_name}" \
    -backend-config="key=quarkus/crossselling/terraform.tfstate" \
    -backend-config="region=${TF_VAR_aws_region}" \
    -backend-config="dynamodb_table=${TF_VAR_dynamodb_table_name}" \
    -backend-config="encrypt=true"
terraform apply -auto-approve
cd ../../..

# ================================================================================

# Kong, Konga and Camunda
cd terraform/Kong
terraform init \
    -backend-config="bucket=${TF_VAR_s3_bucket_name}" \
    -backend-config="key=kongKongaCamunda/terraform.tfstate" \
    -backend-config="region=${TF_VAR_aws_region}" \
    -backend-config="dynamodb_table=${TF_VAR_dynamodb_table_name}" \
    -backend-config="encrypt=true"
terraform apply -auto-approve
cd ../..

# ============================= Export PUBLIC_DNSs ===============================

source scripts/terraform/ExportAddresses.sh

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

source scripts/terraform/PrintAddresses.sh

# ================================================================================

echo "Finished deployment."
echo
