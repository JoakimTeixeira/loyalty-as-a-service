package org.acme;

import org.apache.kafka.clients.consumer.ConsumerRecords;
import org.apache.kafka.clients.consumer.ConsumerRecord;
import org.apache.kafka.clients.consumer.KafkaConsumer;
import org.acme.model.Topic;
import org.apache.kafka.clients.consumer.Consumer;
import org.apache.kafka.clients.consumer.ConsumerConfig;
import org.apache.kafka.common.serialization.StringDeserializer;
import org.eclipse.microprofile.config.inject.ConfigProperty;
import org.json.JSONObject;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.time.Duration;
import java.util.Collections;
import java.util.Properties;

import io.vertx.mutiny.mysqlclient.MySQLPool;
import io.vertx.mutiny.sqlclient.Tuple;
import jakarta.inject.Inject;

public class DynamicTopicConsumer extends Thread {
    private MySQLPool client;
    private String kafkaServers;
    private String topicName;

    private static final Logger LOG = LoggerFactory.getLogger(DynamicTopicConsumer.class);

    @Inject
    public DynamicTopicConsumer(
            MySQLPool client,
            String topicName,
            @ConfigProperty(name = "kafka.bootstrap.servers") String kafkaServers) {
        this.client = client;
        this.topicName = topicName;
        this.kafkaServers = kafkaServers;
    }

    @Override
    public void run() {
        Properties properties = configureKafkaProperties();
        Consumer<String, String> consumer = new KafkaConsumer<>(properties);

        try (consumer) {
            consumer.subscribe(Collections.singletonList(topicName));

            while (true) {
                ConsumerRecords<String, String> records = consumer.poll(Duration.ofMillis(100));

                for (ConsumerRecord<String, String> topicMessage : records) {
                    processTopicMessage(topicMessage);
                }
            }
        } catch (Exception e) {
            LOG.error("Exception in consumer: {}", e.getMessage());
        } finally {
            consumer.close();
            LOG.info("Consumer closed");
        }
    }

    private Properties configureKafkaProperties() {
        Properties properties = new Properties();
        properties.put(ConsumerConfig.BOOTSTRAP_SERVERS_CONFIG, kafkaServers);
        properties.put(ConsumerConfig.KEY_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class.getName());
        properties.put(ConsumerConfig.VALUE_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class.getName());
        properties.put(ConsumerConfig.GROUP_ID_CONFIG, "purchase-group: topic = " + topicName);

        return properties;
    }

    private void processTopicMessage(ConsumerRecord<String, String> topicMessage) {
        try {
            String jsonString = topicMessage.value();
            JSONObject obj = new JSONObject(jsonString);

            final String TOPIC_EVENT_NAME = Topic.getTopicEventName();
            String dateTime = obj.getJSONObject(TOPIC_EVENT_NAME).getString("dateTime");
            String price = obj.getJSONObject(TOPIC_EVENT_NAME).getString("price");
            String product = obj.getJSONObject(TOPIC_EVENT_NAME).getString("product");
            String supplier = obj.getJSONObject(TOPIC_EVENT_NAME).getString("supplier");
            String shopName = obj.getJSONObject(TOPIC_EVENT_NAME).getString("shop");
            String loyaltyCardId = obj.getJSONObject(TOPIC_EVENT_NAME).getString("loyaltyCardId");

            String query = "INSERT INTO purchases (dateTime, price, product, supplier, shopName, loyaltyCardId) VALUES (?, ?, ?, ?, ?, ?)";

            client.preparedQuery(query)
                    .execute(Tuple.of(dateTime, price, product, supplier, shopName, loyaltyCardId))
                    .await().indefinitely();

        } catch (Exception e) {
            LOG.error("Error processing record: {}", e.getMessage(), e);
        }
    }
}
