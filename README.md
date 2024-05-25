# Loyalty-as-a-Service (LaaS)

System to manage loyalty programs for supermarkets

## Running the Project

To get started:

1.  Fork the repository and add your AWS and Docker credentials to the environment variables in the `access.sh` file.

2.  Create an AWS EC2 pair key called `vockey.pem` and move it to the `terraform/Kafka` folder.

3.  This project uses docker to containerize the Quarkus microservices, so log into your docker account with the command:

          docker login

    Or use the `Docker Desktop` application in your operational system

4.  Then run the following command to provision the AWS resources:

          source ./scripts/DeploymentAutomation-ubuntu.sh

    To destroy all resources, run the command:

          source ./scripts/UndeploymentAutomation.sh

    If you want to remove all your credentials from the project, run the command:

          source ./scripts/clean-all-projects.sh

## To-do

- [ ] Automate AWS key pair provisioning
- [ ] Create new microservices
- [ ] Model BPMN diagrams for new microservices
- [ ] Connect microservices using Kong API Gateway
- [ ] Implement Postman scripts for Kong endpoints
- [ ] Model the architecture of the application infrastructure
- [ ] Configure remote status backend (AWS S3) for the Terraform configuration files
