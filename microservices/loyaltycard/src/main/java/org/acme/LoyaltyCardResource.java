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

@Path("LoyaltyCard")
public class LoyaltyCardResource {

    @Inject
    io.vertx.mutiny.mysqlclient.MySQLPool client;

    @Inject
    @ConfigProperty(name = "myapp.schema.create", defaultValue = "true")
    boolean schemaCreate;

    void config(@Observes StartupEvent ev) {
        if (schemaCreate) {
            initdb();
        }
    }

    private void initdb() {
        // In a production environment this configuration SHOULD NOT be used
        client.query("DROP TABLE IF EXISTS loyaltyCards").execute()
                .flatMap(r -> client.query(
                        "CREATE TABLE loyaltyCards (id SERIAL PRIMARY KEY, customerId BIGINT UNSIGNED, shopId BIGINT UNSIGNED, CONSTRAINT UC_Loyal UNIQUE (customerId,shopId))")
                        .execute())
                .flatMap(r -> client.query(" INSERT INTO loyaltyCards (customerId,shopId) VALUES (1,1)").execute())
                .flatMap(r -> client.query(" INSERT INTO loyaltyCards (customerId,shopId) VALUES (2,1)").execute())
                .flatMap(r -> client.query(" INSERT INTO loyaltyCards (customerId,shopId) VALUES (1,3)").execute())
                .flatMap(r -> client.query(" INSERT INTO loyaltyCards (customerId,shopId) VALUES (4,2)").execute())
                .await().indefinitely();
    }

    @GET
    public Multi<LoyaltyCard> get() {
        return LoyaltyCard.findAll(client);
    }

    @GET
    @Path("{id}")
    public Uni<Response> getSingle(Long id) {
        return LoyaltyCard.findById(client, id)
                .onItem()
                .transform(loyaltycard -> loyaltycard != null ? Response.ok(loyaltycard)
                        : Response.status(Response.Status.NOT_FOUND))
                .onItem().transform(ResponseBuilder::build);
    }

    @GET
    @Path("{customerId}/{shopId}")
    public Uni<Response> getDual(Long customerId, Long shopId) {
        return LoyaltyCard.findById2(client, customerId, shopId)
                .onItem()
                .transform(loyaltycard -> loyaltycard != null ? Response.ok(loyaltycard)
                        : Response.status(Response.Status.NOT_FOUND))
                .onItem().transform(ResponseBuilder::build);
    }

    @POST
    public Uni<Response> create(LoyaltyCard loyaltycard) {
        return loyaltycard.save(client, loyaltycard.customerId, loyaltycard.shopId)
                .onItem().transform(id -> URI.create("/loyaltycard/" + id))
                .onItem().transform(uri -> Response.created(uri).build());
    }

    @DELETE
    @Path("{id}")
    public Uni<Response> delete(Long id) {
        return LoyaltyCard.delete(client, id)
                .onItem().transform(deleted -> deleted ? Response.Status.NO_CONTENT : Response.Status.NOT_FOUND)
                .onItem().transform(status -> Response.status(status).build());
    }

    @PUT
    @Path("/{id}/{customerId}/{shopId}")
    public Uni<Response> update(Long id, Long customerId, Long shopId) {
        return LoyaltyCard.update(client, id, customerId, shopId)
                .onItem().transform(updated -> updated ? Response.Status.NO_CONTENT : Response.Status.NOT_FOUND)
                .onItem().transform(status -> Response.status(status).build());
    }

}
