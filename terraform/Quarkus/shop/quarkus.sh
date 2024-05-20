#!/bin/bash
echo "Starting..."

sudo yum install -y docker

sudo service docker start

sudo docker login -u "${dockerhub_username}" -p "'${dockerhub_password}'"

sudo docker pull "${dockerhub_username}/shop:1.0.0-SNAPSHOT"

sudo docker run -d --name shop -p 8080:8080 "${dockerhub_username}/shop:1.0.0-SNAPSHOT"

echo "Finished."
