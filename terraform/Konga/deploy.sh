#!/bin/bash
echo "Starting..."

sudo yum install -y docker

sudo service docker start

sudo docker pull pantsel/konga

sudo docker run -d --name konga -p 1337:1337 pantsel/konga

echo "Finished."
