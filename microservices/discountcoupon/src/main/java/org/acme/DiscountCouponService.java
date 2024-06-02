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
public class DiscountCouponService {
    private final MySQLPool client;
    private final boolean schemaCreate;
    private final String kafkaServers;

    @Inject
    public DiscountCouponService(
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
        client.query("DROP TABLE IF EXISTS discountCoupons").execute()
                .flatMap(r -> client.query(
                        "CREATE TABLE discountCoupons (id SERIAL PRIMARY KEY, discount TEXT NOT NULL, expiryDate DATETIME)")
                        .execute())
                .flatMap(r -> client.query(
                        "INSERT INTO discountCoupons (discount, expiryDate) VALUES ('10% off', '2038-01-19 03:14:07')")
                        .execute())
                .flatMap(r -> client.query(
                        "INSERT INTO discountCoupons (discount, expiryDate) VALUES ('20% off', '2038-01-19 03:14:07')")
                        .execute())
                .await().indefinitely();
    }

    public Multi<DiscountCoupon> getAllCoupons() {
        return client.query("SELECT * FROM discountCoupons")
                .execute()
                .onItem().transformToMulti(rowSet -> Multi.createFrom().iterable(rowSet))
                .onItem().transform(row -> new DiscountCoupon(
                        row.getLong("id"),
                        row.getString("discount"),
                        row.getLocalDateTime("expiryDate").toLocalDate()));
    }

    public Uni<DiscountCoupon> getCouponById(Long id) {
        return client.preparedQuery("SELECT * FROM discountCoupons WHERE id = ?")
                .execute(Tuple.of(id))
                .onItem().transform(rowSet -> {
                    if (rowSet.size() == 0) {
                        return null;
                    } else {
                        var row = rowSet.iterator().next();
                        return new DiscountCoupon(
                                row.getLong("id"),
                                row.getString("discount"),
                                row.getLocalDateTime("expiryDate").toLocalDate());
                    }
                });
    }

    public Uni<DiscountCoupon> createCoupon(DiscountCoupon coupon) {
        return client
                .preparedQuery("INSERT INTO discountCoupons (discount, expiryDate) VALUES (?, ?)")
                .execute(Tuple.of(coupon.getDiscount(), coupon.getExpiryDate()))
                .onItem().transform(ignore -> coupon);
    }

    public Uni<DiscountCoupon> removeCouponById(Long id) {
        return getCouponById(id)
                .onItem().transformToUni(coupon -> {
                    if (coupon == null) {
                        return Uni.createFrom().nullItem();
                    }
                    return client.preparedQuery("DELETE FROM discountCoupons WHERE id = ?")
                            .execute(Tuple.of(id))
                            .onItem().transform(ignore -> coupon);
                });
    }
}
