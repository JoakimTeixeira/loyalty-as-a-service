package org.acme;

import org.apache.kafka.clients.consumer.ConsumerRecords;
import org.apache.kafka.clients.consumer.ConsumerRecord;
import org.apache.kafka.clients.consumer.KafkaConsumer;
import org.apache.kafka.clients.consumer.Consumer;
import org.apache.kafka.clients.consumer.ConsumerConfig;
import org.apache.kafka.common.serialization.StringDeserializer;
import org.acme.model.Topic;
import org.json.JSONObject;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import jakarta.inject.Inject;
import java.time.Duration;
import java.util.Collections;
import java.util.Properties;

public class SelledProductConsumer extends Thread {
    private final SelledProductService selledProductService;
    private final String topicName;

    private static final Logger LOG = LoggerFactory.getLogger(SelledProductConsumer.class);

    @Inject
    public SelledProductConsumer(SelledProductService selledProductService, String topicName) {
        this.selledProductService = selledProductService;
        this.topicName = topicName;
    }

    @Override
    public void run() {
        Properties properties = configureKafkaProperties();
        Consumer<String, String> consumer = new KafkaConsumer<>(properties);

        try (consumer) {
            consumer.subscribe(Collections.singletonList(topicName));

            while (!isInterrupted()) {
                ConsumerRecords<String, String> records = consumer.poll(Duration.ofMillis(100));

                for (ConsumerRecord<String, String> topicMessage : records) {
                    processTopicMessage(topicMessage);
                }
            }
        } catch (Exception e) {
            LOG.error("Exception in consumer: {}", e.getMessage(), e);
        } finally {
            consumer.close();
            LOG.info("Consumer closed");
        }
    }

    private Properties configureKafkaProperties() {
        String kafkaServers = selledProductService.getKafkaServers();
        Properties properties = new Properties();
        properties.put(ConsumerConfig.BOOTSTRAP_SERVERS_CONFIG, kafkaServers);
        properties.put(ConsumerConfig.KEY_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class.getName());
        properties.put(ConsumerConfig.VALUE_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class.getName());
        properties.put(ConsumerConfig.GROUP_ID_CONFIG, "selled-product-group-" + topicName);

        return properties;
    }

    private void processTopicMessage(ConsumerRecord<String, String> topicMessage) {
        try {

            String jsonString = topicMessage.value();
            JSONObject obj = new JSONObject(jsonString);

            final String TOPIC_EVENT_NAME = Topic.getTopicEventName();

            Long couponId = obj.getJSONObject(TOPIC_EVENT_NAME).getLong("couponId");
            Long productsSelledByCoupon = obj.getJSONObject(TOPIC_EVENT_NAME).getLong("productsSelledByCoupon");
            Long shopId = obj.getJSONObject(TOPIC_EVENT_NAME).getLong("shopId");
            Long productsSelledByShop = obj.getJSONObject(TOPIC_EVENT_NAME).getLong("productsSelledByShop");
            String shopLocation = obj.getJSONObject(TOPIC_EVENT_NAME).getString("shopLocation");
            Long productsSelledByLocation = obj.getJSONObject(TOPIC_EVENT_NAME).getLong("productsSelledByLocation");
            Long loyaltyCardId = obj.getJSONObject(TOPIC_EVENT_NAME).getLong("loyaltyCardId");
            Long productsSelledByLoyaltyCard = obj.getJSONObject(TOPIC_EVENT_NAME)
                    .getLong("productsSelledByLoyaltyCard");
            Long customerId = obj.getJSONObject(TOPIC_EVENT_NAME).getLong("customerId");
            Long productsSelledByCustomer = obj.getJSONObject(TOPIC_EVENT_NAME).getLong("productsSelledByCustomer");

            SelledProduct product = new SelledProduct(
                    couponId,
                    productsSelledByCoupon,
                    shopId,
                    productsSelledByShop,
                    shopLocation,
                    productsSelledByLocation,
                    loyaltyCardId,
                    productsSelledByLoyaltyCard,
                    customerId,
                    productsSelledByCustomer);

            selledProductService.createProduct(product).await().indefinitely();

        } catch (Exception e) {
            LOG.error("Error processing record: {}", e.getMessage(), e);
        }
    }
}
