package org.acme;

import jakarta.enterprise.event.Observes;
import jakarta.inject.Inject;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.POST;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.core.Response;
import jakarta.ws.rs.core.Response.ResponseBuilder;

import org.acme.model.Topic;
import org.eclipse.microprofile.config.inject.ConfigProperty;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import io.quarkus.runtime.StartupEvent;
import io.smallrye.mutiny.Multi;
import io.smallrye.mutiny.Uni;
import io.vertx.mutiny.mysqlclient.MySQLPool;

@Path("Purchase")
public class PurchaseResource {
    private final MySQLPool client;
    private final String kafkaServers;
    private final boolean schemaCreate;

    private static final Logger LOG = LoggerFactory.getLogger(PurchaseResource.class);

    @Inject
    public PurchaseResource(
            MySQLPool client,
            @ConfigProperty(name = "kafka.bootstrap.servers") String kafkaServers,
            @ConfigProperty(name = "myapp.schema.create", defaultValue = "true") boolean schemaCreate) {
        this.client = client;
        this.kafkaServers = kafkaServers;
        this.schemaCreate = schemaCreate;
    }

    void config(@Observes StartupEvent ev) {
        if (schemaCreate) {
            initializeDatabase();
        }
    }

    private void initializeDatabase() {
        client.query("DROP TABLE IF EXISTS purchases").execute()
                .flatMap(r -> client.query(
                        "CREATE TABLE purchases (id SERIAL PRIMARY KEY, dateTime DATETIME, price FLOAT, product TEXT NOT NULL, supplier TEXT NOT NULL, shopName TEXT NOT NULL, loyaltyCardId BIGINT UNSIGNED)")
                        .execute())
                .flatMap(r -> client.query(
                        "INSERT INTO purchases (dateTime, price, product, supplier, shopName, loyaltyCardId) VALUES ('2024-01-19 03:14:07', 12.34, 'T-shirt', 'Supplier 1', 'Versace', 1)")
                        .execute())
                .flatMap(r -> client.query(
                        "INSERT INTO purchases (dateTime, price, product, supplier, shopName, loyaltyCardId) VALUES ('2024-01-21 03:14:07', 19.99, 'Jacket', 'Supplier 3', 'Primark', 2)")
                        .execute())
                .flatMap(r -> client.query(
                        "INSERT INTO purchases (dateTime, price, product, supplier, shopName, loyaltyCardId) VALUES ('2024-01-20 03:14:07', 5.67, 'Socks', 'Supplier 2', 'Adidas', 3)")
                        .execute())
                .flatMap(r -> client.query(
                        "INSERT INTO purchases (dateTime, price, product, supplier, shopName, loyaltyCardId) VALUES ('2024-01-22 03:14:07', 23.14, 'Dress', 'Supplier 4', 'H&M', 4)")
                        .execute())
                .await().indefinitely();
    }

    @POST
    @Path("Consume")
    public String provisioningConsumer(Topic topic) {
        try {
            Thread worker = new PurchaseConsumer(client, topic.getTopicName(), kafkaServers);
            worker.start();
            LOG.info("New worker started for topic: {}", topic.getTopicName());
            return "New worker started";
        } catch (Exception e) {
            LOG.error("Failed to start worker for topic: {}", topic.getTopicName(), e);
            return "Failed to start worker";
        }
    }

    @GET
    public Multi<Purchase> get() {
        return Purchase.findAll(client);
    }

    @GET
    @Path("{id}")
    public Uni<Response> getSingle(Long id) {
        return Purchase.findById(client, id)
                .onItem()
                .transform(purchase -> purchase != null ? Response.ok(purchase)
                        : Response.status(Response.Status.NOT_FOUND))
                .onItem().transform(ResponseBuilder::build);
    }
}
