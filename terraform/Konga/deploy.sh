#!/bin/bash

echo "Starting Konga container setup..."

# Install Docker
sudo yum install -y docker

# Start Docker service
sudo service docker start

# Pull Konga Docker image
sudo docker pull pantsel/konga

cat <<EOL >~/userdb.data
module.exports = [
    {
        "username": "teste",
        "email": "myadmin@some.domain",
        "firstName": "John",
        "lastName": "Doe",
        "node_id": "${addressKong}",
        "admin": true,
        "active" : true,
        "password": "testeteste"
    }
]
EOL

cat <<EOL >~/kong_node.data
module.exports = [
    {
        "name": "Kong Node",
        "type": "default",
        "kong_admin_url": "${addressKong}",
        "health_checks": false,
    }
]
EOL

sudo docker run -d --name konga -p 1337:1337 \
    -e "NODE_ENV=production" \
    -e "KONGA_SEED_USER_DATA_SOURCE_FILE=/app/userdb.data" \
    -e "KONGA_SEED_KONG_NODE_DATA_SOURCE_FILE=/app/kong_node.data" \
    -v ~/userdb.data:/app/userdb.data \
    -v ~/kong_node.data:/app/kong_node.data \
    pantsel/konga

echo "Konga container setup finished."
