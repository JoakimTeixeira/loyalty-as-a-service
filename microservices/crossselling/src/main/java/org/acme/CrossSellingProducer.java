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
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import io.smallrye.mutiny.Uni;

import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;
import jakarta.ws.rs.core.Response;

import java.util.Collections;
import java.util.Map;
import java.util.Properties;
import java.util.Set;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.CompletionStage;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.Future;

@ApplicationScoped
public class CrossSellingProducer {
    @ConfigProperty(name = "kafka.bootstrap.servers")
    String kafkaServers;

    @ConfigProperty(name = "kafka.partitions")
    int numPartitions;

    @ConfigProperty(name = "kafka.replication")
    short replicationFactor;

    private static final String MESSAGE_KEY = "message";
    private static final Logger LOG = LoggerFactory.getLogger(CrossSellingProducer.class);
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

    public Uni<Response> sendCrossSellingMessage(String topicName, CrossSelling crossSelling) {
        CompletionStage<RecordMetadata> completionStage = CompletableFuture
                .supplyAsync(() -> {
                    try {
                        return generateRecommendation(
                                topicName,
                                crossSelling.getId(),
                                crossSelling.toString()).get();
                    } catch (ExecutionException e) {
                        throw new IllegalStateException("Failed to generate cross selling", e.getCause());
                    } catch (InterruptedException e) {
                        Thread.currentThread().interrupt(); // Re-interrupt the thread
                        throw new IllegalStateException("Cross Selling crossSelling generation interrupted", e);
                    }
                });

        // Transform CompletionStage to Uni<Response>
        return Uni.createFrom().completionStage(completionStage)
                .onItem().transform(response -> Response.ok(
                        Map.of(MESSAGE_KEY, "Cross selling crossSelling sent: " + response)).build())
                .onFailure().recoverWithItem(error -> Response.serverError().entity(
                        Map.of(MESSAGE_KEY, "Failed to send cross selling crossSelling")).build());

    }

    public Future<RecordMetadata> generateRecommendation(String topicName, Long id, String recommendationContent) {
        String recommendationKey = "Cross-Selling-" + id;
        ProducerRecord<String, String> createdRecommendation = new ProducerRecord<>(topicName, recommendationKey,
                recommendationContent);

        return producer.send(createdRecommendation, (metadata, exception) -> {
            if (exception == null) {
                LOG.info("Successfully sent message to topic {}: partition {}, offset {}",
                        metadata.topic(), metadata.partition(), metadata.offset());
            } else {
                LOG.error("Failed to send message to topic {}", createdRecommendation.topic(), exception);
            }
        });
    }
}
