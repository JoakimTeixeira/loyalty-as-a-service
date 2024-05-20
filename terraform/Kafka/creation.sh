#!/bin/bash

echo "Starting..."
cd

# Install Java
sudo yum -y install java-1.8.0-openjdk.x86_64 

# Installs Zookeeper
sudo wget https://dlcdn.apache.org/zookeeper/zookeeper-3.8.4/apache-zookeeper-3.8.4-bin.tar.gz
sudo tar -zxf apache-zookeeper-3.8.4-bin.tar.gz
sudo mv apache-zookeeper-3.8.4-bin /usr/local/zookeeper
sudo mkdir -p /var/lib/zookeeper

# Election config 1 (Zookeeper):
echo "tickTime=2000
dataDir=/var/lib/zookeeper
clientPort=2181
maxClientCnxns=60
initLimit=10
syncLimit=5" > /usr/local/zookeeper/conf/zoo.cfg 

echo ${idBroker} > /var/lib/zookeeper/myid

# Starts Zookeeper
# # needs to be started before Kafka
sudo /usr/local/zookeeper/bin/zkServer.sh start

# Installs Kafka
sudo wget https://downloads.apache.org/kafka/3.6.2/kafka_2.13-3.6.2.tgz
sudo tar -zxf kafka_2.13-3.6.2.tgz
sudo mv kafka_2.13-3.6.2 /usr/local/kafka
sudo mkdir /tmp/kafka-logs

# Starts Kafka
# # creates initial configuration file "server.properties"
sudo /usr/local/kafka/bin/kafka-server-start.sh -daemon /usr/local/kafka/config/server.properties

# Configures Kafka
ip=`curl http://169.254.169.254/latest/meta-data/public-hostname`
# Searches and replaces comment occurrences (/g) of "#listeners=PLAINTEXT://:9092" with "listeners=PLAINTEXT://$ip:9092" (gets the "ip" above)
sudo sed -i "s/#listeners=PLAINTEXT:\/\/:9092/listeners=PLAINTEXT:\/\/$ip:9092/g" /usr/local/kafka/config/server.properties

# Election config 2: New Kafka + Zookeeper (search and replace scripts)
sudo sed -i "s/broker.id=0/broker.id=${idBroker}/g" /usr/local/kafka/config/server.properties
sudo sed -i "s/offsets.topic.replication.factor=1/offsets.topic.replication.factor=${totalBrokers}/g" /usr/local/kafka/config/server.properties
sudo sed -i "s/transaction.state.log.replication.factor=1/transaction.state.log.replication.factor=${totalBrokers}/g" /usr/local/kafka/config/server.properties
sudo sed -i "s/transaction.state.log.min.isr=1/transaction.state.log.min.isr=${totalBrokers}/g" /usr/local/kafka/config/server.properties

echo "Finished."

