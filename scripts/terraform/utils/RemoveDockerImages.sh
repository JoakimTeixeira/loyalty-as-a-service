#!/bin/bash

# Variables
SERVICES=("purchase" "customer" "shop" "loyaltycard" "discountcoupon" "crossselling")
TAG="1.0.0-SNAPSHOT"

echo "Removing Docker images..."
echo

# Function to remove Docker image locally
remove_local_image() {
    local service=$1
    local full_image_name="${DOCKERHUB_USERNAME}/${service}:${TAG}"

    IMAGE_EXISTS=$(docker images -q "${full_image_name}")

    if [ -n "$IMAGE_EXISTS" ]; then
        docker rmi -f "${full_image_name}"

        if [ $? -eq 0 ]; then
            echo "Docker image ${full_image_name} removed locally."
        else
            echo "Failed to remove image locally."
        fi
    else
        echo "Image doesn't exist locally. Skipping..."
    fi
    echo
}

# Function to remove Docker repository from Docker Hub
remove_dockerhub_repository() {
    local service=$1
    local repo_name="${DOCKERHUB_USERNAME}/${service}"

    # Login to Docker Hub and get token
    token=$(curl -s -H "Content-Type: application/json" -X POST -d '{"username": "'"${DOCKERHUB_USERNAME}"'", "password": "'"${DOCKERHUB_PASSWORD}"'"}' https://hub.docker.com/v2/users/login/ | grep -o '"token":"[^"]*' | sed 's/"token":"//')

    if [ -z "$token" ]; then
        echo "Failed to log into Docker Hub. Skipping..."
        echo
        return
    fi

    # Delete the entire repository from Docker Hub
    response=$(curl -s -o /dev/null -w "%{http_code}" -X DELETE "https://hub.docker.com/v2/repositories/${repo_name}/" -H "Authorization: Bearer ${token}")

    if [ "$response" -eq 202 ]; then
        echo "Repository ${repo_name} removed from Docker Hub."
    else
        echo "Image not found in Docker Hub. Skipping..."
    fi
    echo
}

# Main script
if [ -z "${DOCKERHUB_USERNAME}" ] || [ -z "${DOCKERHUB_PASSWORD}" ]; then
    echo "Docker Hub username or password not set."
else
    echo
    for service in "${SERVICES[@]}"; do
        remove_local_image "$service"
        remove_dockerhub_repository "$service"
        echo "===================================================="
        echo
    done
fi

echo "Docker images removed."
