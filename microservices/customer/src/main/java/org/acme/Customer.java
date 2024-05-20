package org.acme;

import io.smallrye.mutiny.Multi;
import io.smallrye.mutiny.Uni;
import io.vertx.mutiny.mysqlclient.MySQLPool;
import io.vertx.mutiny.sqlclient.Row;
import io.vertx.mutiny.sqlclient.RowSet;
import io.vertx.mutiny.sqlclient.Tuple;

public class Customer {
	
	 	public Long FiscalNumber;
	    public Long id;
		public String location;
		public String name;

	    public Customer() {
	    }

	    public Customer(String name) {
	        this.name = name;
	    }

	    public Customer(Long id, String name) {
	        this.id = id;
	        this.name = name;
	    }
		
	    public Customer(Long iD, String name_R , String location_R , Long FiscalNumber_R ) {
			FiscalNumber = FiscalNumber_R;
			id = iD;
			location = location_R;
			name = name_R;
		}

		@Override
		public String toString() {
			return "{FiscalNumber:" + FiscalNumber + ", id:" + id + ", location:" + location + ", name:" + name
					+ "}\n";
		}

		private static Customer from(Row row) {
	        return new Customer(row.getLong("id"), row.getString("name") , row.getString("location") , row.getLong("FiscalNumber") );
	    }
	    
	    public static Multi<Customer> findAll(MySQLPool client) {
	        return client.query("SELECT id, name, FiscalNumber , location FROM Customers ORDER BY id ASC").execute()
	                .onItem().transformToMulti(set -> Multi.createFrom().iterable(set))
	                .onItem().transform(Customer::from);
	    }
	    
	    public static Uni<Customer> findById(MySQLPool client, Long id) {
	        return client.preparedQuery("SELECT id, name, FiscalNumber , location FROM Customers WHERE id = ?").execute(Tuple.of(id)) 
	                .onItem().transform(RowSet::iterator) 
	                .onItem().transform(iterator -> iterator.hasNext() ? from(iterator.next()) : null); 
	    }
	    
	    public Uni<Boolean> save(MySQLPool client , String name_R, Long fnumber , String loc) 
		{
	        return client.preparedQuery("INSERT INTO Customers(name,FiscalNumber,location) VALUES (?,?,?)").execute(Tuple.of(name_R ,fnumber , loc))
	        		.onItem().transform(pgRowSet -> pgRowSet.rowCount() == 1 ); 
	    }
	    
	    public static Uni<Boolean> delete(MySQLPool client, Long id_R) {
	        return client.preparedQuery("DELETE FROM Customers WHERE id = ?").execute(Tuple.of(id_R))
	                .onItem().transform(pgRowSet -> pgRowSet.rowCount() == 1); 
	    }
	    
	    public static Uni<Boolean> update(MySQLPool client, Long id_R, String name_R, Long fnumber , String loc) {
	        return client.preparedQuery("UPDATE Customers SET name = ?, FiscalNumber = ? , location = ? WHERE id = ?").execute(Tuple.of(name_R,fnumber,loc,id_R))
	        		.onItem().transform(pgRowSet -> pgRowSet.rowCount() == 1 ); 
	    }  
}
