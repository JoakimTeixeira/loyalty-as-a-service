#!/bin/bash

BASE_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")")
cd "$BASE_DIR"

source ./scripts/access.sh

# ================================================================================

# Terraform 1 - RDS
cd terraform/RDS
terraform init
terraform apply -auto-approve
esc=$'\e'
export addressRDS="$(terraform state show aws_db_instance.rds_db | grep address | sed "s/address//g" | sed "s/=//g" | sed "s/\"//g" | sed "s/ //g" | sed "s/$esc\[[0-9;]*m//g")"
cd ../..

# ================================================================================

# Terraform 2 - Kafka
cd terraform/Kafka
terraform init
terraform apply -auto-approve
esc=$'\e'
# addresskafka2=$(terraform state list 'aws_instance.kafkaCluster' | xargs -I {} terraform state show {} | grep public_dns | awk '{print $3}' | tr -d '"' | paste -sd ',' -)
export addresskafka="$(terraform state show 'aws_instance.kafkaCluster[0]' | grep public_dns | sed "s/public_dns//g" | sed "s/=//g" | sed "s/\"//g" | sed "s/ //g" | sed "s/$esc\[[0-9;]*m//g")"
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

cd ../../..
./mvnw clean package
cd ../..

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

cd ../../..
./mvnw clean package
cd ../..

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

cd ../../..
./mvnw clean package
cd ../..

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

# ===================== Showing all the PUBLIC_DNSs =====================

cd terraform/RDS
echo "RDS IS AVAILABLE HERE:"
echo "${addressRDS}"
echo
cd ../..

cd terraform/Kafka
echo "KAFKA IS AVAILABLE HERE:"
echo "${addresskafka}"
echo
cd ../..

cd terraform/Quarkus/Purchase
echo "MICROSERVICE purchase IS AVAILABLE HERE:"
export pathPurchase="$(terraform state show aws_instance.purchaseQuarkus | grep public_dns | sed "s/public_dns//g" | sed "s/=//g" | sed "s/\"//g" | sed "s/ //g" | sed "s/$esc\[[0-9;]*m//g")"
echo "http://${pathPurchase}:8080/q/swagger-ui/"
echo
cd ../../..

cd terraform/Quarkus/customer
echo "MICROSERVICE customer IS AVAILABLE HERE:"
export pathCustomer="$(terraform state show aws_instance.customerQuarkus | grep public_dns | sed "s/public_dns//g" | sed "s/=//g" | sed "s/\"//g" | sed "s/ //g" | sed "s/$esc\[[0-9;]*m//g")"
echo "http://${pathCustomer}:8080/q/swagger-ui/"
echo
cd ../../..

cd terraform/Quarkus/shop
echo "MICROSERVICE shop IS AVAILABLE HERE:"
export pathShop="$(terraform state show aws_instance.shopQuarkus | grep public_dns | sed "s/public_dns//g" | sed "s/=//g" | sed "s/\"//g" | sed "s/ //g" | sed "s/$esc\[[0-9;]*m//g")"
echo "http://${pathShop}:8080/q/swagger-ui/"
echo
cd ../../..

cd terraform/Quarkus/loyaltycard
echo "MICROSERVICE loyaltycard IS AVAILABLE HERE:"
export pathLoyaltyCard="$(terraform state show aws_instance.loyaltyCardQuarkus | grep public_dns | sed "s/public_dns//g" | sed "s/=//g" | sed "s/\"//g" | sed "s/ //g" | sed "s/$esc\[[0-9;]*m//g")"
echo "http://${pathLoyaltyCard}:8080/q/swagger-ui/"
echo
cd ../../..

cd terraform/Kong
echo "KONG IS AVAILABLE HERE:"
export addressKong="$(terraform state show aws_instance.installKong | grep public_dns | sed "s/public_dns//g" | sed "s/=//g" | sed "s/\"//g" | sed "s/ //g" | sed "s/$esc\[[0-9;]*m//g")"
echo "http://${addressKong}:8001/"
echo
cd ../..

cd terraform/Konga
echo "KONGA IS AVAILABLE HERE:"
addressKonga="$(terraform state show aws_instance.installKonga | grep public_dns | sed "s/public_dns//g" | sed "s/=//g" | sed "s/\"//g" | sed "s/ //g" | sed "s/$esc\[[0-9;]*m//g")"
echo "http://${addressKonga}:1337/"
echo
cd ../..

cd terraform/Camunda
echo "CAMUNDA IS AVAILABLE HERE:"
addressCamunda="$(terraform state show aws_instance.installCamundaEngine | grep public_dns | sed "s/public_dns//g" | sed "s/=//g" | sed "s/\"//g" | sed "s/ //g" | sed "s/$esc\[[0-9;]*m//g")"
echo "http://${addressCamunda}:8080/camunda"
echo
cd ../..
