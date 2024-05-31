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
- [x] Create Kong scripts to serve as API Gateway for the microservices
- [x] Implement Postman scripts for E2E tests of BPMN diagrams
- [ ] Connect microservices via Kong API Gateway
- [ ] Adapt Postman scripts to use Kong endpoints
- [ ] Update deploy script to leverage multiple Kafka instances
- [ ] Automate AWS key pairs provisioning
- [ ] Develop a script to update Zookeeper and Kafka configs on reboot
- [ ] Configure terraform state to be backed up in AWS S3
- [ ] Model architecture diagram for application infrastructure
