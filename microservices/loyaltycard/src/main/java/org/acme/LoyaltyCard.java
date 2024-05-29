package org.acme;

import io.smallrye.mutiny.Multi;
import io.smallrye.mutiny.Uni;
import io.vertx.mutiny.mysqlclient.MySQLPool;
import io.vertx.mutiny.sqlclient.Row;
import io.vertx.mutiny.sqlclient.RowSet;
import io.vertx.mutiny.sqlclient.Tuple;

public class LoyaltyCard {

	public Long id;
	public Long customerId;
	public Long shopId;

	public LoyaltyCard() {
	}

	public LoyaltyCard(Long id, Long customerId, Long shopId) {
		this.id = id;
		this.customerId = customerId;
		this.shopId = shopId;
	}

	@Override
	public String toString() {
		return "{id:" + id + ", customerId:" + customerId + ", shopId:" + shopId + "}\n";
	}

	private static LoyaltyCard from(Row row) {
		return new LoyaltyCard(row.getLong("id"), row.getLong("customerId"), row.getLong("shopId"));
	}

	public static Multi<LoyaltyCard> findAll(MySQLPool client) {
		return client.query("SELECT id, customerId, shopId FROM loyaltyCards ORDER BY id ASC").execute()
				.onItem().transformToMulti(set -> Multi.createFrom().iterable(set))
				.onItem().transform(LoyaltyCard::from);
	}

	public static Uni<LoyaltyCard> findById(MySQLPool client, Long id) {
		return client.preparedQuery("SELECT id, customerId, shopId FROM loyaltyCards WHERE id = ?")
				.execute(Tuple.of(id))
				.onItem().transform(RowSet::iterator)
				.onItem().transform(iterator -> iterator.hasNext() ? from(iterator.next()) : null);
	}

	public static Uni<LoyaltyCard> findById2(MySQLPool client, Long customerId, Long shopId) {
		return client
				.preparedQuery("SELECT id, customerId, shopId FROM loyaltyCards WHERE customerId = ? AND shopId = ?")
				.execute(Tuple.of(customerId, shopId))
				.onItem().transform(RowSet::iterator)
				.onItem().transform(iterator -> iterator.hasNext() ? from(iterator.next()) : null);

	}

	public Uni<Boolean> save(MySQLPool client, Long CustomerId_R, Long shopId_R) {
		return client.preparedQuery("INSERT INTO loyaltyCards(customerId,shopId) VALUES (?,?)")
				.execute(Tuple.of(CustomerId_R, shopId_R))
				.onItem().transform(pgRowSet -> pgRowSet.rowCount() == 1);
	}

	public static Uni<Boolean> delete(MySQLPool client, Long id_R) {
		return client.preparedQuery("DELETE FROM loyaltyCards WHERE id = ?").execute(Tuple.of(id_R))
				.onItem().transform(pgRowSet -> pgRowSet.rowCount() == 1);
	}

	public static Uni<Boolean> update(MySQLPool client, Long id_R, Long CustomerId_R, Long shopId_R) {
		return client.preparedQuery("UPDATE loyaltyCards SET customerId = ? , shopId = ? WHERE id = ?")
				.execute(Tuple.of(CustomerId_R, shopId_R, id_R))
				.onItem().transform(pgRowSet -> pgRowSet.rowCount() == 1);
	}
}
