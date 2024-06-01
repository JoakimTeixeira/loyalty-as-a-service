#!/bin/bash

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$BASE_DIR"

# Accesses the "pathKong" variable exported by ExportAddresses.sh after running DeploymentAutomation-ubuntu.sh

echo
echo "Starting BPMN file update..."
echo

# Ensure the "pathKong" variable is set
if [[ -z "$pathKong" ]]; then
    echo "The variable \"pathKong\" is empty, please export it and try again. Exiting..."
else
    addressKong="http://${pathKong}:8000"

    # # Insert the addressKong variable as value where it has an ec2 address
    for file in bpmn/*.bpmn; do
        sed -i 's|\(<camunda:inputParameter name="url">\)http://ec2-[^</]*|\1'"$addressKong"'|' "$file"
    done

    echo "Finished updating BPMN files."
    echo
fi
