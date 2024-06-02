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
import java.time.LocalDate;
import java.util.Collections;
import java.util.Properties;

public class DiscountCouponConsumer extends Thread {
    private final DiscountCouponService discountCouponService;
    private final String topicName;

    private static final Logger LOG = LoggerFactory.getLogger(DiscountCouponConsumer.class);

    @Inject
    public DiscountCouponConsumer(DiscountCouponService discountCouponService, String topicName) {
        this.discountCouponService = discountCouponService;
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
            LOG.error("Exception in consumer: {}", e.getMessage());
        } finally {
            consumer.close();
            LOG.info("Consumer closed");
        }
    }

    private Properties configureKafkaProperties() {
        String kafkaServers = discountCouponService.getKafkaServers();
        Properties properties = new Properties();
        properties.put(ConsumerConfig.BOOTSTRAP_SERVERS_CONFIG, kafkaServers);
        properties.put(ConsumerConfig.KEY_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class.getName());
        properties.put(ConsumerConfig.VALUE_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class.getName());
        properties.put(ConsumerConfig.GROUP_ID_CONFIG, "discount-coupon-group-" + topicName);

        return properties;
    }

    private void processTopicMessage(ConsumerRecord<String, String> topicMessage) {
        try {
            String jsonString = topicMessage.value();
            JSONObject obj = new JSONObject(jsonString);

            final String TOPIC_EVENT_NAME = Topic.getTopicEventName();
            String discount = obj.getJSONObject(TOPIC_EVENT_NAME).getString("discount");
            String expiryDate = obj.getJSONObject(TOPIC_EVENT_NAME).getString("expiryDate");

            DiscountCoupon coupon = new DiscountCoupon(discount, LocalDate.parse(expiryDate));
            discountCouponService.createCoupon(coupon).await().indefinitely();

        } catch (Exception e) {
            LOG.error("Error processing record: {}", e.getMessage());
        }
    }
}
