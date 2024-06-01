#!/bin/bash

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$BASE_DIR"

# Accesses the "pathCamunda" variable exported by ExportAddresses.sh after running DeploymentAutomation-ubuntu.sh

echo "Starting JSON file update..."
echo

# Ensure the "pathCamunda" variable is set
if [[ -z "$pathCamunda" ]]; then
    echo "The variable \"pathCamunda\" is empty, please export it and try again. Exiting..."
else
    addressCamunda="http://${pathCamunda}"
    JSON_FILE="bpmn/tests/CamundaWorkflows.postman_collection.json"

    # Insert the addressCamunda variable as value after the tag "host"
    sed -i '/"key": "host"/!b;n;s|"value": ".*"|"value": "'"$addressCamunda"'"|g' "$JSON_FILE"

    echo "Finished updating JSON file."
    echo
fi
