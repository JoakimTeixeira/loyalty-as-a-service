package org.acme;

import java.net.URI;
import jakarta.enterprise.event.Observes;
import jakarta.inject.Inject;
import jakarta.ws.rs.*;
import org.eclipse.microprofile.config.inject.ConfigProperty;
import io.quarkus.runtime.StartupEvent;
import io.smallrye.mutiny.Multi;
import io.smallrye.mutiny.Uni;
import jakarta.ws.rs.core.Response;
import jakarta.ws.rs.core.Response.ResponseBuilder;
import jakarta.ws.rs.core.MediaType;

@Path("Shop")
public class ShopResource {

    @Inject
    io.vertx.mutiny.mysqlclient.MySQLPool client;
    
    @Inject
    @ConfigProperty(name = "myapp.schema.create", defaultValue = "true") 
    boolean schemaCreate ;

    void config(@Observes StartupEvent ev) {
        if (schemaCreate) {
            initdb();
        }
    }
    
    private void initdb() {
        // In a production environment this configuration SHOULD NOT be used
        client.query("DROP TABLE IF EXISTS Shops").execute()
        .flatMap(r -> client.query("CREATE TABLE Shops (id SERIAL PRIMARY KEY, name TEXT NOT NULL, location TEXT NOT NULL)").execute())
        .flatMap(r -> client.query("INSERT INTO Shops (name,location) VALUES ('client1','Lisbon')").execute())
        .flatMap(r -> client.query("INSERT INTO Shops (name,location) VALUES ('client2','Setúbal')").execute())
        .flatMap(r -> client.query("INSERT INTO Shops (name,location) VALUES ('client3','OPorto')").execute())
        .flatMap(r -> client.query("INSERT INTO Shops (name,location) VALUES ('client4','Faro')").execute())
        .await().indefinitely();
    }
    
    @GET
    public Multi<Shop> get() {
        return Shop.findAll(client);
    }
    
    @GET
    @Path("{id}")
    public Uni<Response> getSingle(Long id) {
        return Shop.findById(client, id)
                .onItem().transform(shop -> shop != null ? Response.ok(shop) : Response.status(Response.Status.NOT_FOUND)) 
                .onItem().transform(ResponseBuilder::build); 
    }
     
    @POST
    public Uni<Response> create(Shop shop) {
        return shop.save(client , shop.name , shop.location)
                .onItem().transform(id -> URI.create("/shop/" + id))
                .onItem().transform(uri -> Response.created(uri).build());
    }
    
    @DELETE
    @Path("{id}")
    public Uni<Response> delete(Long id) {
        return Shop.delete(client, id)
                .onItem().transform(deleted -> deleted ? Response.Status.NO_CONTENT : Response.Status.NOT_FOUND)
                .onItem().transform(status -> Response.status(status).build());
    }

    @PUT
    @Path("/{id}/{name}/{location}")
    public Uni<Response> update(Long id , String name , String location) {
        return Shop.update(client, id , name , location)
                .onItem().transform(updated -> updated ? Response.Status.NO_CONTENT : Response.Status.NOT_FOUND)
                .onItem().transform(status -> Response.status(status).build());
    }
    
}
