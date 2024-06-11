package org.acme;

import java.time.LocalDateTime;

import org.acme.model.Topic;
import org.json.JSONObject;

import io.smallrye.mutiny.Multi;
import io.smallrye.mutiny.Uni;
import io.vertx.mutiny.mysqlclient.MySQLPool;
import io.vertx.mutiny.sqlclient.Row;
import io.vertx.mutiny.sqlclient.RowSet;
import io.vertx.mutiny.sqlclient.Tuple;

public class Purchase {
    private Long id;
    private LocalDateTime dateTime;
    private Float price;
    private String product;
    private String supplier;
    private String shopName;
    private Long loyaltyCardId;

    public Long getId() {
        return id;
    }

    public LocalDateTime getDateTime() {
        return dateTime;
    }

    public Float getPrice() {
        return price;
    }

    public String getProduct() {
        return product;
    }

    public String getSupplier() {
        return supplier;
    }

    public String getShopName() {
        return shopName;
    }

    public Long getLoyaltyCardId() {
        return loyaltyCardId;
    }

    public Purchase(Long id, LocalDateTime dateTime, Float price, String product, String supplier,
            String shopName, Long loyaltyCardId) {
        this.id = id;
        this.dateTime = dateTime;
        this.price = price;
        this.product = product;
        this.supplier = supplier;
        this.shopName = shopName;
        this.loyaltyCardId = loyaltyCardId;
    }

    public Purchase() {
    }

    public String serializeContent() {
        final String TOPIC_EVENT_NAME = Topic.getTopicEventName();

        return new JSONObject().put(TOPIC_EVENT_NAME, new JSONObject()
                .put("id", this.getId())
                .put("dateTime", this.getDateTime().toString())
                .put("price", this.getPrice())
                .put("product", this.getProduct())
                .put("supplier", this.getSupplier())
                .put("shopName", this.getShopName())
                .put("loyaltyCardId", this.getProduct()))
                .toString();
    }

    private static Purchase from(Row row) {

        return new Purchase(row.getLong("id"),
                row.getLocalDateTime("dateTime"),
                row.getFloat("price"),
                row.getString("product"),
                row.getString("supplier"),
                row.getString("shopName"),
                row.getLong("loyaltyCardId"));

    }

    public static Multi<Purchase> findAll(MySQLPool client) {
        return client.query(
                "SELECT id, dateTime, price, product , supplier, shopName, loyaltyCardId FROM purchases ORDER BY id ASC")
                .execute()
                .onItem().transformToMulti(set -> Multi.createFrom().iterable(set))
                .onItem().transform(Purchase::from);
    }

    public static Uni<Purchase> findById(MySQLPool client, Long id) {
        return client.preparedQuery(
                "SELECT id, dateTime, price, product , supplier, shopName, loyaltyCardId FROM purchases WHERE id = ?")
                .execute(Tuple.of(id))
                .onItem().transform(RowSet::iterator)
                .onItem().transform(iterator -> iterator.hasNext() ? from(iterator.next()) : null);
    }

}
