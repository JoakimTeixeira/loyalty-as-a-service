package org.acme;

import io.smallrye.mutiny.Multi;
import io.smallrye.mutiny.Uni;
import io.vertx.mutiny.mysqlclient.MySQLPool;
import io.vertx.mutiny.sqlclient.Row;
import io.vertx.mutiny.sqlclient.RowSet;
import io.vertx.mutiny.sqlclient.Tuple;

public class Loyaltycard {
	
	    public Long id;
		public Long idCustomer;
		public Long idShop;

	    public Loyaltycard() {
	    }

	

		public Loyaltycard(Long id, Long idCustomer, Long idShop) {
			this.id = id;
			this.idCustomer = idCustomer;
			this.idShop = idShop;
		}



		@Override
		public String toString() {
			return "{id:" + id + ", idCustomer:" + idCustomer + ", idShop:" + idShop + "}\n";
		}

		private static Loyaltycard from(Row row) {
	        return new Loyaltycard(row.getLong("id"), row.getLong("idCustomer") , row.getLong("idShop"));
	    }
	    
	    public static Multi<Loyaltycard> findAll(MySQLPool client) {
	        return client.query("SELECT id, idCustomer, idShop  FROM LoyaltyCards ORDER BY id ASC").execute()
	                .onItem().transformToMulti(set -> Multi.createFrom().iterable(set))
	                .onItem().transform(Loyaltycard::from);
	    }
	    
	    public static Uni<Loyaltycard> findById(MySQLPool client, Long id) {
	        return client.preparedQuery("SELECT id, idCustomer, idShop  FROM LoyaltyCards WHERE id = ?").execute(Tuple.of(id)) 
	                .onItem().transform(RowSet::iterator) 
	                .onItem().transform(iterator -> iterator.hasNext() ? from(iterator.next()) : null); 
	    }

		public static Uni<Loyaltycard> findById2(MySQLPool client, Long idCustomer , Long idShop) {
	        return client.preparedQuery("SELECT id, idCustomer, idShop FROM LoyaltyCards WHERE idCustomer = ? AND idShop = ?").execute(Tuple.of(idCustomer , idShop)) 
	                .onItem().transform(RowSet::iterator) 
	                .onItem().transform(iterator -> iterator.hasNext() ? from(iterator.next()) : null); 
					
	    }

	    public Uni<Boolean> save(MySQLPool client , Long idCustomer_R , Long idShop_R) 
		{
	        return client.preparedQuery("INSERT INTO LoyaltyCards(idCustomer,idShop) VALUES (?,?)").execute(Tuple.of(idCustomer_R , idShop_R))
	        		.onItem().transform(pgRowSet -> pgRowSet.rowCount() == 1 ); 
	    }
	    
	    public static Uni<Boolean> delete(MySQLPool client, Long id_R) {
	        return client.preparedQuery("DELETE FROM LoyaltyCards WHERE id = ?").execute(Tuple.of(id_R))
	                .onItem().transform(pgRowSet -> pgRowSet.rowCount() == 1); 
	    }
	    
	    public static Uni<Boolean> update(MySQLPool client, Long id_R, Long idCustomer_R , Long idShop_R ) {
	        return client.preparedQuery("UPDATE LoyaltyCards SET idCustomer = ? , idShop = ? WHERE id = ?").execute(Tuple.of(idCustomer_R,idShop_R,id_R))
	        		.onItem().transform(pgRowSet -> pgRowSet.rowCount() == 1 ); 
	    }  
}
