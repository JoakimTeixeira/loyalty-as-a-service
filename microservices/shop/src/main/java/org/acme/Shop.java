package org.acme;

import io.smallrye.mutiny.Multi;
import io.smallrye.mutiny.Uni;
import io.vertx.mutiny.mysqlclient.MySQLPool;
import io.vertx.mutiny.sqlclient.Row;
import io.vertx.mutiny.sqlclient.RowSet;
import io.vertx.mutiny.sqlclient.Tuple;

public class Shop {
	
	 	
	    public Long id;
		public String location;
		public String name;

	    public Shop() {
	    }

	    public Shop(String name) {
	        this.name = name;
	    }

	    public Shop(Long id, String name) {
	        this.id = id;
	        this.name = name;
	    }
		
	    public Shop(Long iD, String name_R , String location_R ) {
			id = iD;
			location = location_R;
			name = name_R;
		}

		@Override
		public String toString() {
			return "{ id:" + id + ", location:" + location + ", name:" + name + "}\n";
		}

		private static Shop from(Row row) {
	        return new Shop(row.getLong("id"), row.getString("name") , row.getString("location") );
	    }
	    
	    public static Multi<Shop> findAll(MySQLPool client) {
	        return client.query("SELECT id, name, location FROM Shops ORDER BY id ASC").execute()
	                .onItem().transformToMulti(set -> Multi.createFrom().iterable(set))
	                .onItem().transform(Shop::from);
	    }
	    
	    public static Uni<Shop> findById(MySQLPool client, Long id) {
	        return client.preparedQuery("SELECT id, name, location FROM Shops WHERE id = ?").execute(Tuple.of(id)) 
	                .onItem().transform(RowSet::iterator) 
	                .onItem().transform(iterator -> iterator.hasNext() ? from(iterator.next()) : null); 
	    }
	    
	    public Uni<Boolean> save(MySQLPool client , String name_R, String loc) 
		{
	        return client.preparedQuery("INSERT INTO Shops(name,location) VALUES (?,?)").execute(Tuple.of(name_R , loc))
	        		.onItem().transform(pgRowSet -> pgRowSet.rowCount() == 1 ); 
	    }
	    
	    public static Uni<Boolean> delete(MySQLPool client, Long id_R) {
	        return client.preparedQuery("DELETE FROM Shops WHERE id = ?").execute(Tuple.of(id_R))
	                .onItem().transform(pgRowSet -> pgRowSet.rowCount() == 1); 
	    }
	    
	    public static Uni<Boolean> update(MySQLPool client, Long id_R, String name_R, String loc) {
	        return client.preparedQuery("UPDATE Shops SET name = ?, location = ? WHERE id = ?").execute(Tuple.of(name_R,loc,id_R))
	        		.onItem().transform(pgRowSet -> pgRowSet.rowCount() == 1 ); 
	    }  
}
