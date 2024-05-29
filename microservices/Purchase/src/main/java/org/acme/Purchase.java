package org.acme;

import io.smallrye.mutiny.Multi;
import io.smallrye.mutiny.Uni;
import io.vertx.mutiny.mysqlclient.MySQLPool;
import io.vertx.mutiny.sqlclient.Row;
import io.vertx.mutiny.sqlclient.RowSet;
import io.vertx.mutiny.sqlclient.Tuple;

public class Purchase {
    public Long id;
    public java.time.LocalDateTime dateTime;
    public Float price;
    public String product;
    public String supplier;
    public String shopName;
    public Long loyaltyCardId;

    public Purchase(Long id, java.time.LocalDateTime dateTime, Float price, String product, String supplier,
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

    @Override
    public String toString() {
        return "{id=" + id + ", dateTime=" + dateTime.toString() + ", price=" + price + ", product=" + product
                + ", supplier="
                + supplier + ", shopName=" + shopName + ", loyaltyCardId=" + loyaltyCardId + "}";
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
