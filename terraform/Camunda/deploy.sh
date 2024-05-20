#!/bin/bash
echo "Starting..."

sudo yum update -y

sudo yum install -y docker

sudo service docker start

sudo docker pull camunda/camunda-bpm-platform:latest

sudo docker run -d --name camunda -p 8080:8080 camunda/camunda-bpm-platform:latest

echo "Finished."
