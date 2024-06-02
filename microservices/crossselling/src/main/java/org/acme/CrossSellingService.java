package org.acme;

import io.smallrye.mutiny.Multi;
import io.smallrye.mutiny.Uni;
import io.vertx.mutiny.mysqlclient.MySQLPool;
import io.vertx.mutiny.sqlclient.Tuple;
import org.eclipse.microprofile.config.inject.ConfigProperty;

import jakarta.enterprise.context.ApplicationScoped;
import jakarta.enterprise.event.Observes;
import jakarta.inject.Inject;
import io.quarkus.runtime.StartupEvent;

@ApplicationScoped
public class CrossSellingService {
    private final MySQLPool client;
    private final boolean schemaCreate;
    private final String kafkaServers;

    @Inject
    public CrossSellingService(
            MySQLPool client,
            @ConfigProperty(name = "myapp.schema.create", defaultValue = "true") boolean schemaCreate,
            @ConfigProperty(name = "kafka.bootstrap.servers") String kafkaServers) {
        this.client = client;
        this.schemaCreate = schemaCreate;
        this.kafkaServers = kafkaServers;
    }

    public MySQLPool getClient() {
        return client;
    }

    public String getKafkaServers() {
        return kafkaServers;
    }

    void config(@Observes StartupEvent ev) {
        if (schemaCreate) {
            initializeDatabase();
        }
    }

    private void initializeDatabase() {
        client.query("DROP TABLE IF EXISTS crossSellings").execute()
                .flatMap(r -> client.query(
                        "CREATE TABLE crossSellings (id SERIAL PRIMARY KEY, partnerShop TEXT NOT NULL, recommendedProduct TEXT NOT NULL)")
                        .execute())
                .flatMap(r -> client.query(
                        "INSERT INTO crossSellings (partnerShop, recommendedProduct) VALUES ('H&M', 'T-Shirt')")
                        .execute())
                .flatMap(r -> client.query(
                        "INSERT INTO crossSellings (partnerShop, recommendedProduct) VALUES ('H&M', 'Hoodie')")
                        .execute())
                .await().indefinitely();
    }

    public Multi<CrossSelling> getAllRecommendations() {
        return client.query("SELECT * FROM crossSellings")
                .execute()
                .onItem().transformToMulti(rowSet -> Multi.createFrom().iterable(rowSet))
                .onItem().transform(row -> new CrossSelling(
                        row.getLong("id"),
                        row.getString("partnerShop"),
                        row.getString("recommendedProduct")));
    }

    public Uni<CrossSelling> getRecommendationById(Long id) {
        return client.preparedQuery("SELECT * FROM crossSellings WHERE id = ?")
                .execute(Tuple.of(id))
                .onItem().transform(rowSet -> {
                    if (rowSet.size() == 0) {
                        return null;
                    } else {
                        var row = rowSet.iterator().next();
                        return new CrossSelling(
                                row.getLong("id"),
                                row.getString("partnerShop"),
                                row.getString("recommendedProduct"));
                    }
                });
    }

    public Uni<CrossSelling> createRecommendation(CrossSelling crossSelling) {
        return client
                .preparedQuery("INSERT INTO crossSellings (partnerShop, recommendedProduct) VALUES (?, ?)")
                .execute(Tuple.of(crossSelling.getPartnerShop(), crossSelling.getRecommendedProduct()))
                .onItem().transform(ignore -> crossSelling);
    }

    public Uni<CrossSelling> removeRecommendationById(Long id) {
        return getRecommendationById(id)
                .onItem().transformToUni(crossSelling -> {
                    if (crossSelling == null) {
                        return Uni.createFrom().nullItem();
                    }
                    return client.preparedQuery("DELETE FROM crossSellings WHERE id = ?")
                            .execute(Tuple.of(id))
                            .onItem().transform(ignore -> crossSelling);
                });
    }
}
