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

5.  Camunda is responsible for orchestrating the business logic of the application. To deploy the Camunda BPMN files, open the Camunda Modeler program and enter this URL as the deployment URL:

            http://<CAMUNDA-AWS-EC2-PUBLIC-DNS>:8080/engine-rest/deployment/create

## To-do

- [ ] Create new microservices
- [ ] Model BPMN diagrams for new microservices
- [ ] Write new Postman scripts to automate E2E tests for BPMN diagrams
- [ ] Connect microservices using Kong API Gateway
- [ ] Implement Postman scripts for Kong endpoints
- [ ] Fix Deploy script to handle multiple Kafka instances
- [ ] Automate AWS key pair provisioning
- [ ] Develop a script to update Zookeeper and Kafka configuration files when instance reboots
- [ ] Configure remote status backend (AWS S3) for backing up Terraform state files
- [ ] Model the architecture of the application infrastructure
