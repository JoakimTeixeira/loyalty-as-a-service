package org.acme;

import org.apache.kafka.clients.admin.Admin;
import org.apache.kafka.clients.admin.CreateTopicsResult;
import org.apache.kafka.clients.admin.NewTopic;
import org.apache.kafka.clients.producer.KafkaProducer;
import org.apache.kafka.clients.producer.Producer;
import org.apache.kafka.clients.producer.ProducerConfig;
import org.apache.kafka.clients.producer.ProducerRecord;
import org.apache.kafka.clients.producer.RecordMetadata;
import org.apache.kafka.common.KafkaFuture;
import org.apache.kafka.common.serialization.StringSerializer;
import org.eclipse.microprofile.config.inject.ConfigProperty;
import org.json.JSONObject;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import io.smallrye.mutiny.Uni;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;
import jakarta.ws.rs.core.Response;

import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.Properties;
import java.util.Set;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.Future;

@ApplicationScoped
public class SelledProductProducer {
    @ConfigProperty(name = "kafka.bootstrap.servers")
    String kafkaServers;

    @ConfigProperty(name = "kafka.partitions")
    int numPartitions;

    @ConfigProperty(name = "kafka.replication")
    short replicationFactor;

    private static final String MESSAGE_KEY = "message";
    private static final Logger LOG = LoggerFactory.getLogger(SelledProductProducer.class);
    private Producer<String, String> producer;

    @Inject
    public void init() {
        Properties properties = configureKafkaProperties();
        producer = new KafkaProducer<>(properties);
    }

    private Properties configureKafkaProperties() {
        Properties properties = new Properties();
        properties.put(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG, kafkaServers);
        properties.put(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG, StringSerializer.class.getName());
        properties.put(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG, StringSerializer.class.getName());

        return properties;
    }

    private Properties configureTopicProperties() {
        Properties properties = new Properties();
        properties.put(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG, kafkaServers);
        properties.put(ProducerConfig.CONNECTIONS_MAX_IDLE_MS_CONFIG, 10000);
        properties.put(ProducerConfig.REQUEST_TIMEOUT_MS_CONFIG, 5000);

        return properties;
    }

    public Uni<Boolean> createTopic(String topicName) {
        return Uni.createFrom().item(() -> {
            Properties properties = configureTopicProperties();
            Admin topicAdmin = Admin.create(properties);

            try (topicAdmin) {
                NewTopic newTopic = new NewTopic(topicName, numPartitions, replicationFactor);
                CreateTopicsResult result = topicAdmin.createTopics(Collections.singleton(newTopic));

                // Wait for results and return true if the topic was created
                KafkaFuture<Void> future = result.values().get(topicName);
                future.get();

                return true;
            } catch (ExecutionException e) {
                throw new IllegalStateException(e.getMessage(), e);
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt(); // Re-interrupt the thread
                throw new IllegalStateException(e.getMessage(), e);
            }
        });
    }

    public Uni<Boolean> topicExists(String topicName) {
        Properties properties = configureTopicProperties();
        Admin topicAdmin = Admin.create(properties);

        try (topicAdmin) {
            Set<String> topics = topicAdmin.listTopics().names().get();
            return Uni.createFrom().item(topics.contains(topicName));
        } catch (ExecutionException e) {
            throw new IllegalStateException(e.getMessage(), e);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt(); // Re-interrupt the thread
            throw new IllegalStateException(e.getMessage(), e);
        } catch (Exception e) {
            return Uni.createFrom().item(false);
        }
    }

    public Uni<Response> sendSelledProductMessage(String baseTopicName, SelledProduct product) {
        List<String> topicNames = Arrays.asList(
                baseTopicName + "-selledByCoupon",
                baseTopicName + "-selledByShop",
                baseTopicName + "-selledByLocation",
                baseTopicName + "-selledByLoyaltyCard",
                baseTopicName + "-selledByCustomer");

        List<Uni<RecordMetadata>> sendResults = topicNames.stream()
                .map(topicName -> Uni.createFrom().completionStage(() -> CompletableFuture.supplyAsync(() -> {
                    try {
                        if (topicName.equals(topicNames.get(0))) {
                            String message = new JSONObject().put("Selled_Product_Event", new JSONObject()
                                    .put("couponId", product.getCouponId())
                                    .put("productsSelledByCoupon", product.getProductsSelledByCoupon()))
                                    .toString();

                            return generateProduct(topicName, product.getId(), message).get();
                        }

                        if (topicName.equals(topicNames.get(1))) {
                            String message = new JSONObject().put("Selled_Product_Event", new JSONObject()
                                    .put("shopId", product.getShopId())
                                    .put("productsSelledByShop", product.getProductsSelledByShop()))
                                    .toString();

                            return generateProduct(topicName, product.getId(), message).get();

                        }

                        if (topicName.equals(topicNames.get(2))) {
                            String message = new JSONObject().put("Selled_Product_Event", new JSONObject()
                                    .put("shopLocation", product.getShopLocation())
                                    .put("productsSelledByLocation", product.getProductsSelledByLocation()))
                                    .toString();

                            return generateProduct(topicName, product.getId(), message).get();
                        }

                        if (topicName.equals(topicNames.get(3))) {
                            String message = new JSONObject().put("Selled_Product_Event", new JSONObject()
                                    .put("loyaltyCardId", product.getLoyaltyCardId())
                                    .put("productsSelledByLoyaltyCard", product.getProductsSelledByLoyaltyCard()))
                                    .toString();

                            return generateProduct(topicName, product.getId(), message).get();

                        }

                        if (topicName.equals(topicNames.get(4))) {
                            String message = new JSONObject().put("Selled_Product_Event", new JSONObject()
                                    .put("customerId", product.getCustomerId())
                                    .put("productsSelledByCustomer", product.getProductsSelledByCustomer()))
                                    .toString();

                            return generateProduct(topicName, product.getId(), message).get();

                        }

                        return null;
                    } catch (ExecutionException e) {
                        throw new IllegalStateException("Failed to generate product", e.getCause());
                    } catch (InterruptedException e) {
                        Thread.currentThread().interrupt(); // Re-interrupt the thread
                        throw new IllegalStateException("Product generation interrupted", e);
                    }
                })))
                .toList();

        return Uni.combine().all().unis(sendResults)
                .combinedWith(results -> {
                    boolean allSent = results.stream().allMatch(result -> result != null);
                    if (allSent) {
                        return Response.ok(Map.of(MESSAGE_KEY, "Selled Product messages sent to all topics")).build();
                    } else {
                        return Response.serverError().entity(
                                Map.of(MESSAGE_KEY, "Failed to send selled product message to one or more topics"))
                                .build();
                    }
                });
    }

    public Future<RecordMetadata> generateProduct(String topicName, Long id, String productContent) {
        String productKey = "Product-" + id;
        ProducerRecord<String, String> createdProduct = new ProducerRecord<>(topicName, productKey, productContent);

        return producer.send(createdProduct, (metadata, exception) -> {
            if (exception == null) {
                LOG.info("Successfully sent message to topic {}: partition {}, offset {}",
                        metadata.topic(), metadata.partition(), metadata.offset());
            } else {
                LOG.error("Failed to send message to topic {}", createdProduct.topic(), exception);
            }
        });
    }
}
