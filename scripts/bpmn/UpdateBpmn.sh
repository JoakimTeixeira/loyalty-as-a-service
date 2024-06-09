#!/bin/bash

BASE_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)
cd "$BASE_DIR"

# Accesses the "pathKongKongaCamunda" variable exported by ExportAddresses.sh after running DeploymentAutomation-ubuntu.sh

echo
echo "Starting BPMN file update..."
echo

# Ensure the "pathKongKongaCamunda" variable is set
if [[ -z "$pathKongKongaCamunda" ]]; then
    echo "The variable \"pathKongKongaCamunda\" is empty, please export it and try again. Exiting..."
else
    addressKong="http://${pathKongKongaCamunda}:8000"

    # # Insert the addressKong variable as value where it has an ec2 address
    for file in bpmn/*.bpmn; do
        sed -i 's|\(<camunda:inputParameter name="url">\)http://ec2-[^</]*|\1'"$addressKong"'|' "$file"
    done

    echo "Finished updating BPMN files."
    echo
fi
