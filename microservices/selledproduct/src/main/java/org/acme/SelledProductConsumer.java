package org.acme;

import org.apache.kafka.clients.consumer.ConsumerRecords;
import org.apache.kafka.clients.consumer.ConsumerRecord;
import org.apache.kafka.clients.consumer.KafkaConsumer;
import org.apache.kafka.clients.consumer.Consumer;
import org.apache.kafka.clients.consumer.ConsumerConfig;
import org.apache.kafka.common.serialization.StringDeserializer;
import org.json.JSONObject;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import jakarta.inject.Inject;
import java.time.Duration;
import java.util.Arrays;
import java.util.List;
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

        List<String> topics = Arrays.asList(
                topicName + "-selledByCoupon",
                topicName + "-selledByShop",
                topicName + "-selledByLocation",
                topicName + "-selledByLoyaltyCard",
                topicName + "-selledByCustomer");

        try (consumer) {
            consumer.subscribe(topics);

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

            // The key for the event name inside the JSON object
            final String TOPIC_EVENT_NAME = "Selled_Product_Event";

            // Extracting data from the JSON object
            Long couponId = obj.optJSONObject(TOPIC_EVENT_NAME).optLong("couponId", -1);
            Long productsSelledByCoupon = obj.optJSONObject(TOPIC_EVENT_NAME).optLong("productsSelledByCoupon", -1);
            Long shopId = obj.optJSONObject(TOPIC_EVENT_NAME).optLong("shopId", -1);
            Long productsSelledByShop = obj.optJSONObject(TOPIC_EVENT_NAME).optLong("productsSelledByShop", -1);
            String shopLocation = obj.optJSONObject(TOPIC_EVENT_NAME).optString("shopLocation", "");
            Long productsSelledByLocation = obj.optJSONObject(TOPIC_EVENT_NAME).optLong("productsSelledByLocation", -1);
            Long loyaltyCardId = obj.optJSONObject(TOPIC_EVENT_NAME).optLong("loyaltyCardId", -1);
            Long productsSelledByLoyaltyCard = obj.optJSONObject(TOPIC_EVENT_NAME)
                    .optLong("productsSelledByLoyaltyCard", -1);
            Long customerId = obj.optJSONObject(TOPIC_EVENT_NAME).optLong("customerId", -1);
            Long productsSelledByCustomer = obj.optJSONObject(TOPIC_EVENT_NAME).optLong("productsSelledByCustomer", -1);

            // Creating SelledProduct object
            SelledProduct product = new SelledProduct(
                    couponId != -1 ? couponId : null,
                    productsSelledByCoupon != -1 ? productsSelledByCoupon : null,
                    shopId != -1 ? shopId : null,
                    productsSelledByShop != -1 ? productsSelledByShop : null,
                    shopLocation,
                    productsSelledByLocation != -1 ? productsSelledByLocation : null,
                    loyaltyCardId != -1 ? loyaltyCardId : null,
                    productsSelledByLoyaltyCard != -1 ? productsSelledByLoyaltyCard : null,
                    customerId != -1 ? customerId : null,
                    productsSelledByCustomer != -1 ? productsSelledByCustomer : null);

            // Persisting the product using selledProductService
            selledProductService.createProduct(product).await().indefinitely();

        } catch (Exception e) {
            LOG.error("Error processing record: {}", e.getMessage(), e);
        }
    }

}
