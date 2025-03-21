# Loyalty-as-a-Service (LaaS)

Distributed, automated, and highly scalable supermarket chain management system

## Running the Project

To get started:

1.  Fork the repository, clone it, and add your AWS and Docker credentials to the environment variables in the `Access.sh` file.

2.  This project uses docker to containerize the Quarkus microservices, so log into your docker account with the command:

          docker login

    Or use the `Docker Desktop` application in your operational system

3.  Then run the following command to provision the AWS resources:

          source ./scripts/terraform/DeploymentAutomation-ubuntu.sh

    To destroy all resources, run the command:

          source ./scripts/terraform/UndeploymentAutomation.sh

    If you want to remove all your credentials from the project, run the command:

          source ./scripts/auth/CleanProject.sh

4.  Camunda is responsible for orchestrating the business logic of the application. To deploy the Camunda BPMN files, open the Camunda Modeler program and enter this URL as the deployment URL:

            http://<CAMUNDA-AWS-EC2-PUBLIC-DNS>:8080/engine-rest/deployment/create

## To-do

- [x] Implement Postman scripts for E2E tests of BPMN diagrams
- [x] Model BPMN diagrams for new microservices
- [x] Adapt BPMN diagrams in Camunda Modeler so microservices can communicate through Kong endpoints
- [x] Automate EC2 URL replacement in BPMN diagrams (XML files) and Postman script
- [x] Automate Kong routes and servers creation
- [x] Automate Kong and Konga configuration on docker images
- [x] Automate Konga UI to initiate with custom admin user + Kong connection
- [x] Create Kong scripts to serve as API Gateway for the microservices
- [x] Automate AWS key pairs provisioning
- [x] Implement the "sold product" microservice
- [x] Configure terraform state to be backed up in AWS S3
- [x] Make the terraform state detect changes when Quarkus docker image is created
- [x] Automate cleanup of Quarkus docker images from the local machine and Docker Hub
- [x] Avoid creating Kong services and routes again if they already exist
- [x] Integrate an RDS database into each microservice to decrease coupling
- [x] Modularize Terraform configuration files and directories
- [ ] Update replacement script (sed) to leverage multiple Kafka instances in the same machine
- [ ] Replace Java/Kafka microservice modules to use NestJS + [@confluentinc/kafka-javascript](https://github.com/confluentinc/confluent-kafka-javascript)
- [ ] Refactor business logic of BPMN diagrams
- [ ] Improve the database architecture to increase data consistency
- [ ] Implement a web interface to interact with data from microservices
- [ ] Migrate [Konga GUI](https://github.com/pantsel/konga) to [Kong Manager](https://github.com/Kong/kong-manager)
- [ ] Document architecture
