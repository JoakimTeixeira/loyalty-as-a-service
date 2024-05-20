#!/bin/bash

BASE_DIR=$( cd "$(dirname "${BASH_SOURCE[0]}")")
cd "$BASE_DIR"

# Remove all credentials from access.sh file
sed -i 's/^aws_access_key_id=.*/aws_access_key_id='""'/' scripts/access.sh
sed -i 's/^aws_secret_access_key=.*/aws_secret_access_key='""'/' scripts/access.sh
sed -i 's/^aws_session_token=.*/aws_session_token='""'/' scripts/access.sh
sed -i 's/^export TF_VAR_dockerhub_password=.*/export TF_VAR_dockerhub_password='""'/' scripts/access.sh
sed -i 's/^export TF_VAR_dockerhub_username=.*/export TF_VAR_dockerhub_username='""'/' scripts/access.sh

# Remove all credentials from microservices' configuration files
cd microservices/customer/src/main/resources
sed -i 's/^quarkus\.container-image\.group=.*/quarkus.container-image.group='""'/' application.properties
sed -i 's/^quarkus\.datasource\.reactive\.url=.*/quarkus.datasource.reactive.url='""'/' application.properties
sed -i 's/^kafka\.bootstrap\.servers=.*/kafka.bootstrap.servers='""'/' application.properties
cd ../../../../../

cd microservices/loyaltycard/src/main/resources
sed -i 's/^quarkus\.container-image\.group=.*/quarkus.container-image.group='""'/' application.properties
sed -i 's/^quarkus\.datasource\.reactive\.url=.*/quarkus.datasource.reactive.url='""'/' application.properties
sed -i 's/^kafka\.bootstrap\.servers=.*/kafka.bootstrap.servers='""'/' application.properties
cd ../../../../../

cd microservices/Purchase/src/main/resources
sed -i 's/^quarkus\.container-image\.group=.*/quarkus.container-image.group='""'/' application.properties
sed -i 's/^quarkus\.datasource\.reactive\.url=.*/quarkus.datasource.reactive.url='""'/' application.properties
sed -i 's/^kafka\.bootstrap\.servers=.*/kafka.bootstrap.servers='""'/' application.properties
cd ../../../../../

cd microservices/shop/src/main/resources
sed -i 's/^quarkus\.container-image\.group=.*/quarkus.container-image.group='""'/' application.properties
sed -i 's/^quarkus\.datasource\.reactive\.url=.*/quarkus.datasource.reactive.url='""'/' application.properties
sed -i 's/^kafka\.bootstrap\.servers=.*/kafka.bootstrap.servers='""'/' application.properties
cd ../../../../../

# Remove all compilation files from Terraform
find . \( -name ".terraform" -o -name ".terraform.lock.hcl" -o -name ".terraform.tfstate.lock.info" -o -name "terraform.tfstate" -o -name "terraform.tfstate.backup" \) -exec rm -rf {} +

# Remove all compilation files from microservices
find . \( -name "target" \) -type d -exec rm -rf {} +
