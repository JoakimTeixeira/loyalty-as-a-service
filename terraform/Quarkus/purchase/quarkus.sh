#!/bin/bash
echo "Starting..."

sudo yum install -y docker

sudo service docker start

sudo docker login -u "${dockerhub_username}" -p "'${dockerhub_password}'"

sudo docker pull "${dockerhub_username}/purchase:1.0.0-SNAPSHOT"

sudo docker run -d --name purchase -p 8080:8080 "${dockerhub_username}/purchase:1.0.0-SNAPSHOT"

echo "The docker image hash is: ${dockerhub_image_hash}"

echo "Finished."
