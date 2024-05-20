#!/bin/bash

echo "Starting..."
cd

# Stop Zookeeper and Kafka
sleep 90
sudo sed -i "s/^zookeeper\.connect=.*/zookeeper.connect=$(echo "$ALL_PUBLIC_DNS" | sed 's/, */:2181,/g'):2181/" /usr/local/kafka/config/server.properties

# Configure Zookeeper properties
echo "$ALL_PUBLIC_DNS" | tr ',' '\n' | awk -v dns="$ALL_PUBLIC_DNS" '{print "server." NR "=" $0 ":2888:3888"}' | sudo tee -a /usr/local/zookeeper/conf/zoo.cfg >/dev/null

# Start Zookeeper
sudo /usr/local/zookeeper/bin/zkServer.sh stop && echo "Stoped Zookeeper"
sudo /usr/local/zookeeper/bin/zkServer.sh start && echo "Started Zookeeper"

# Start Kafka
sleep 20
# sudo /usr/local/kafka/bin/kafka-server-start.sh -daemon /usr/local/kafka/config/server.properties
sudo /usr/local/kafka/bin/kafka-server-start.sh -daemon /usr/local/kafka/config/server.properties && echo "Started Kafka"

sleep 5

# (Optional) Create all topics using SSH
# CURRENT_PUBLIC_DNS=$(curl -s http://169.254.169.254/latest/meta-data/public-hostname)

# sudo /usr/local/kafka/bin/kafka-topics.sh --create --bootstrap-server "$CURRENT_PUBLIC_DNS:9092" -replication-factor $TOTAL_BROKERS --partitions 4 --topic DISCOUNT_COUPON && echo "Topic 1 created!"
# sudo /usr/local/kafka/bin/kafka-topics.sh --create --bootstrap-server "$CURRENT_PUBLIC_DNS:9092" -replication-factor $TOTAL_BROKERS --partitions 4 --topic CROSS_SELLING_RECOMMENDATION && echo "Topic 2 created!"
# sudo /usr/local/kafka/bin/kafka-topics.sh --create --bootstrap-server "$CURRENT_PUBLIC_DNS:9092" -replication-factor $TOTAL_BROKERS --partitions 4 --topic SELLED_PRODUCT_BY_COUPON && echo "Topic 3 created!"
# sudo /usr/local/kafka/bin/kafka-topics.sh --create --bootstrap-server "$CURRENT_PUBLIC_DNS:9092" -replication-factor $TOTAL_BROKERS --partitions 4 --topic SELLED_PRODUCT_BY_CUSTOMER && echo "Topic 4 created!"
# sudo /usr/local/kafka/bin/kafka-topics.sh --create --bootstrap-server "$CURRENT_PUBLIC_DNS:9092" -replication-factor $TOTAL_BROKERS --partitions 4 --topic SELLED_PRODUCT_BY_LOCATION && echo "Topic 5 created!"
# sudo /usr/local/kafka/bin/kafka-topics.sh --create --bootstrap-server "$CURRENT_PUBLIC_DNS:9092" -replication-factor $TOTAL_BROKERS --partitions 4 --topic SELLED_PRODUCT_BY_LOYALTY_CARD && echo "Topic 4 created!"
# sudo /usr/local/kafka/bin/kafka-topics.sh --create --bootstrap-server "$CURRENT_PUBLIC_DNS:9092" -replication-factor $TOTAL_BROKERS --partitions 4 --topic SELLED_PRODUCT_BY_SHOP && echo "Topic 7 created!"

echo "Finished."