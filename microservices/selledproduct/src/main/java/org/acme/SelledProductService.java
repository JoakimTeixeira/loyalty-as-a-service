package org.acme;

import io.smallrye.mutiny.Multi;
import io.smallrye.mutiny.Uni;
import io.vertx.mutiny.mysqlclient.MySQLPool;
import io.vertx.mutiny.sqlclient.Tuple;

import java.util.Arrays;

import org.eclipse.microprofile.config.inject.ConfigProperty;

import jakarta.enterprise.context.ApplicationScoped;
import jakarta.enterprise.event.Observes;
import jakarta.inject.Inject;
import io.quarkus.runtime.StartupEvent;

@ApplicationScoped
public class SelledProductService {
    private final MySQLPool client;
    private final boolean schemaCreate;
    private final String kafkaServers;

    @Inject
    public SelledProductService(
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
        client.query("DROP TABLE IF EXISTS selledProducts").execute()
                .flatMap(r -> client.query(
                        "CREATE TABLE selledProducts (id SERIAL PRIMARY KEY, couponId BIGINT UNSIGNED, productsSelledByCoupon BIGINT UNSIGNED, shopId BIGINT UNSIGNED, productsSelledByShop BIGINT UNSIGNED, shopLocation VARCHAR(255), productsSelledByLocation BIGINT UNSIGNED, loyaltyCardId BIGINT UNSIGNED, productsSelledByLoyaltyCard BIGINT UNSIGNED, customerId BIGINT UNSIGNED, productsSelledByCustomer BIGINT UNSIGNED)")
                        .execute())
                .flatMap(r -> client.query(
                        "INSERT INTO selledProducts (couponId, productsSelledByCoupon, shopId, productsSelledByShop, shopLocation, productsSelledByLocation, loyaltyCardId, productsSelledByLoyaltyCard, customerId, productsSelledByCustomer) VALUES (1, 1, 1, 1, 'Aveiro', 1, 1, 1, 1, 1)")
                        .execute())
                .flatMap(r -> client.query(
                        "INSERT INTO selledProducts (couponId, productsSelledByCoupon, shopId, productsSelledByShop, shopLocation, productsSelledByLocation, loyaltyCardId, productsSelledByLoyaltyCard, customerId, productsSelledByCustomer) VALUES (2, 2, 2, 2, 'Lisboa', 2, 2, 2, 2, 2)")
                        .execute())
                .await().indefinitely();
    }

    public Multi<SelledProduct> getAllProducts() {
        return client.query("SELECT * FROM selledProducts")
                .execute()
                .onItem().transformToMulti(rowSet -> Multi.createFrom().iterable(rowSet))
                .onItem().transform(row -> new SelledProduct(
                        row.getLong("id"),
                        row.getLong("couponId"),
                        row.getLong("productsSelledByCoupon"),
                        row.getLong("shopId"),
                        row.getLong("productsSelledByShop"),
                        row.getString("shopLocation"),
                        row.getLong("productsSelledByLocation"),
                        row.getLong("loyaltyCardId"),
                        row.getLong("productsSelledByLoyaltyCard"),
                        row.getLong("customerId"),
                        row.getLong("productsSelledByCustomer")));
    }

    public Uni<SelledProduct> getProductById(Long id) {
        return client.preparedQuery("SELECT * FROM selledProducts WHERE id = ?")
                .execute(Tuple.of(id))
                .onItem().transform(rowSet -> {
                    if (rowSet.size() == 0) {
                        return null;
                    } else {
                        var row = rowSet.iterator().next();
                        return new SelledProduct(
                                row.getLong("id"),
                                row.getLong("couponId"),
                                row.getLong("productsSelledByCoupon"),
                                row.getLong("shopId"),
                                row.getLong("productsSelledByShop"),
                                row.getString("shopLocation"),
                                row.getLong("productsSelledByLocation"),
                                row.getLong("loyaltyCardId"),
                                row.getLong("productsSelledByLoyaltyCard"),
                                row.getLong("customerId"),
                                row.getLong("productsSelledByCustomer"));
                    }
                });
    }

    public Uni<SelledProduct> createProduct(SelledProduct product) {
        return client
                .preparedQuery(
                        "INSERT INTO selledProducts (couponId, productsSelledByCoupon, shopId, productsSelledByShop, shopLocation, productsSelledByLocation, loyaltyCardId, productsSelledByLoyaltyCard, customerId, productsSelledByCustomer) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)")
                .execute(Tuple.tuple(Arrays.asList(
                        product.getCouponId(),
                        product.getProductsSelledByCoupon(),
                        product.getShopId(),
                        product.getProductsSelledByShop(),
                        product.getShopLocation(),
                        product.getProductsSelledByLocation(),
                        product.getLoyaltyCardId(),
                        product.getProductsSelledByLoyaltyCard(),
                        product.getCustomerId(),
                        product.getProductsSelledByCustomer())))
                .onItem().transform(ignore -> product);
    }

    public Uni<SelledProduct> removeProductById(Long id) {
        return getProductById(id)
                .onItem().transformToUni(product -> {
                    if (product == null) {
                        return Uni.createFrom().nullItem();
                    }
                    return client.preparedQuery("DELETE FROM selledProducts WHERE id = ?")
                            .execute(Tuple.of(id))
                            .onItem().transform(ignore -> product);
                });
    }
}
