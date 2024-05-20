# Loyalty-as-a-Service (LaaS)

System to manage loyalty programs for supermarkets

## Running the Project

To get started, fork the repository and add your AWS and Docker credentials to the environment variables in the `access.sh` file.

Also create a AWS EC2 pair key called `vockey.pem` and move it to the `terraform/Kafka` folder.

Then run the following command to provision the AWS resources:

    source ./scripts/DeploymentAutomation-ubuntu.sh

To destroy all resources, run he command:

    source ./scripts/UndeploymentAutomation.sh

If you want to remove all your credentials from the project, run the command:

    source ./scripts/clean-all-projects.sh
