#!/bin/bash

# Get the directory of the script
BASE_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)
cd "$BASE_DIR"

echo
echo "Cleaning the entire project..."
echo

# Check if Access.sh exists and remove all credentials if it does
clean_access() {
    local access_dir=$1

    if [ -f "$access_dir" ]; then
        sed -i "s/^aws_access_key_id=.*/aws_access_key_id=''/g" "$access_dir"
        sed -i "s/^aws_secret_access_key=.*/aws_secret_access_key=''/g" "$access_dir"
        sed -i "s/^aws_session_token=.*/aws_session_token=''/g" "$access_dir"
        sed -i "s/^export DOCKERHUB_USERNAME=.*/export DOCKERHUB_USERNAME=''/g" "$access_dir"
        sed -i "s/^export DOCKERHUB_PASSWORD=.*/export DOCKERHUB_PASSWORD=''/g" "$access_dir"
        sed -i "s/^export DB_USERNAME=.*/export DB_USERNAME=''/g" "$access_dir"
        sed -i "s/^export DB_PASSWORD=.*/export DB_PASSWORD=''/g" "$access_dir"
    else
        echo "Warning: $access_dir not found."
    fi
}

# Function to clean microservice configuration files
clean_microservice() {
    local service_dir=$1
    local file="$service_dir/src/main/resources/application.properties"

    if [ -f "$file" ]; then
        sed -i "s/^quarkus\.datasource\.username=.*/quarkus.datasource.username=''/g" "$file"
        sed -i "s/^quarkus\.datasource\.password=.*/quarkus.datasource.password=''/g" "$file"
        sed -i "s/^quarkus\.container-image\.group=.*/quarkus.container-image.group=''/g" "$file"
        sed -i "s/^quarkus\.datasource\.reactive\.url=.*/quarkus.datasource.reactive.url=''/g" "$file"
        sed -i "s/^kafka\.bootstrap\.servers=.*/kafka.bootstrap.servers=''/g" "$file"
    else
        echo "Warning: $file not found."
    fi
}

clean_bpmn() {
    local bpmn_dir=$1
    for file in $bpmn_dir/*.bpmn; do
        if [ -f "$file" ]; then
            sed -i 's|\(<camunda:inputParameter name="url">\)http://ec2-[^</]*|\1'"http://ec2-KONG_URL"'|' "$file"
        fi
    done
}

clean_postman() {
    local json_dir=$1
    for file in $json_dir/*.json; do
        if [ -f "$file" ]; then
            sed -i '/"key": "host"/!b;n;s|"value": ".*"|"value": "http://ec2-CAMUNDA_URL"|g' "$file"
        fi
    done

}

# Clean credentials from configuration files
clean_access "scripts/auth/Access.sh"
clean_microservice "microservices/purchase"
clean_microservice "microservices/shop"
clean_microservice "microservices/customer"
clean_microservice "microservices/loyaltycard"
clean_microservice "microservices/discountcoupon"
clean_microservice "microservices/crossselling"
clean_bpmn "bpmn"
clean_postman "bpmn/tests"

# Remove all compilation files from Terraform
find . \( -name ".terraform" -o -name "backend-config.hcl" -o -name "errored.tfstate" -o -name ".terraform.tfstate.lock.info" -o -name "terraform.tfstate" -o -name "terraform.tfstate.backup" \) -exec rm -rf {} +

# Remove all compilation files from microservices
find . \( -name "target" \) -type d -exec rm -rf {} +

echo "Project was cleaned!"
echo
