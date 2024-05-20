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

@Path("Loyaltycard")
public class LoyaltycardResource {

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
        client.query("DROP TABLE IF EXISTS LoyaltyCards").execute()
        .flatMap(r -> client.query("CREATE TABLE LoyaltyCards (id SERIAL PRIMARY KEY, idCustomer BIGINT UNSIGNED, idShop BIGINT UNSIGNED, CONSTRAINT UC_Loyal UNIQUE (idCustomer,idShop))").execute())
        .flatMap(r -> client.query(" INSERT INTO LoyaltyCards (idCustomer,idShop) VALUES (1,1)").execute())
        .flatMap(r -> client.query(" INSERT INTO LoyaltyCards (idCustomer,idShop) VALUES (2,1)").execute())
        .flatMap(r -> client.query(" INSERT INTO LoyaltyCards (idCustomer,idShop) VALUES (1,3)").execute())
        .flatMap(r -> client.query(" INSERT INTO LoyaltyCards (idCustomer,idShop) VALUES (4,2)").execute())
        .await().indefinitely();
    }
    
    @GET
    public Multi<Loyaltycard> get() {
        return Loyaltycard.findAll(client);
    }
    
    @GET
    @Path("{id}")
    public Uni<Response> getSingle(Long id) {
        return Loyaltycard.findById(client, id)
                .onItem().transform(loyaltycard -> loyaltycard != null ? Response.ok(loyaltycard) : Response.status(Response.Status.NOT_FOUND)) 
                .onItem().transform(ResponseBuilder::build); 
    }
     
    @GET
    @Path("{idCustomer}/{idShop}")
    public Uni<Response> getDual(Long idCustomer, Long idShop) {
        return Loyaltycard.findById2(client, idCustomer, idShop)
                .onItem().transform(loyaltycard -> loyaltycard != null ? Response.ok(loyaltycard) : Response.status(Response.Status.NOT_FOUND)) 
                .onItem().transform(ResponseBuilder::build); 
    }

    @POST
    public Uni<Response> create(Loyaltycard loyaltycard) {
        return loyaltycard.save(client , loyaltycard.idCustomer , loyaltycard.idShop)
                .onItem().transform(id -> URI.create("/loyaltycard/" + id))
                .onItem().transform(uri -> Response.created(uri).build());
    }
    
    @DELETE
    @Path("{id}")
    public Uni<Response> delete(Long id) {
        return Loyaltycard.delete(client, id)
                .onItem().transform(deleted -> deleted ? Response.Status.NO_CONTENT : Response.Status.NOT_FOUND)
                .onItem().transform(status -> Response.status(status).build());
    }

    @PUT
    @Path("/{id}/{idCustomer}/{idShop}")
    public Uni<Response> update(Long id , Long idCustomer , Long idShop ) {
        return Loyaltycard.update(client, id, idCustomer , idShop )
                .onItem().transform(updated -> updated ? Response.Status.NO_CONTENT : Response.Status.NOT_FOUND)
                .onItem().transform(status -> Response.status(status).build());
    }
    
}
