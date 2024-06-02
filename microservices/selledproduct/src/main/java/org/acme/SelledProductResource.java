package org.acme;

import org.acme.model.TopicProduct;
import org.acme.model.Topic;

import io.smallrye.mutiny.Multi;
import io.smallrye.mutiny.Uni;

import jakarta.inject.Inject;
import jakarta.ws.rs.*;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;

import java.util.Map;

@Path("/SelledProduct")
public class SelledProductResource {
    private final SelledProductService selledProductService;
    private final SelledProductProducer selledProductProducer;

    private static final String MESSAGE_KEY = "message";

    @Inject
    public SelledProductResource(
            SelledProductService selledProductService,
            SelledProductProducer selledProductProducer) {
        this.selledProductService = selledProductService;
        this.selledProductProducer = selledProductProducer;
    }

    @POST
    @Path("Consume")
    @Produces(MediaType.APPLICATION_JSON)
    @Consumes(MediaType.APPLICATION_JSON)
    public Uni<Response> provisioningConsumer(Topic topic) {
        try {
            Thread worker = new SelledProductConsumer(selledProductService, topic.getTopicName());
            worker.start();
            return Uni.createFrom().item(Response.ok().entity(
                    Map.of(MESSAGE_KEY, "New worker started: " + topic.getTopicName())).build());
        } catch (Exception e) {
            e.printStackTrace();
            return Uni.createFrom().item(Response.serverError().entity(
                    Map.of(MESSAGE_KEY, "Failed to start worker")).build());
        }
    }

    @GET
    @Produces(MediaType.APPLICATION_JSON)
    @Consumes(MediaType.APPLICATION_JSON)
    public Multi<SelledProduct> getAll() {
        return selledProductService.getAllProducts();
    }

    @POST
    @Produces(MediaType.APPLICATION_JSON)
    @Consumes(MediaType.APPLICATION_JSON)
    public Uni<Response> generateSelledProduct(TopicProduct request) {
        String topicName = request.getTopic().getTopicName();
        SelledProduct product = request.getProduct();

        return selledProductProducer.topicExists(topicName)
                .onItem().transformToUni(exists -> {
                    if (!exists.booleanValue()) {
                        return handleTopicCreation(topicName).onItem().transformToUni(
                                response -> selledProductProducer.sendSelledProductMessage(topicName, product));
                    } else {
                        return selledProductProducer.sendSelledProductMessage(topicName, product);
                    }
                });
    }

    private Uni<Response> handleTopicCreation(String topicName) {
        return selledProductProducer.createTopic(topicName)
                .onItem().transform(isCreated -> {
                    if (!isCreated.booleanValue()) {
                        return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                                .entity(Map.of(MESSAGE_KEY, "Failed to create topic")).build();
                    } else {
                        return Response.status(Response.Status.OK)
                                .entity(Map.of(MESSAGE_KEY, "Topic created successfully")).build();
                    }
                });
    }

    @GET
    @Path("{id}")
    @Produces(MediaType.APPLICATION_JSON)
    @Consumes(MediaType.APPLICATION_JSON)
    public Uni<Response> getById(@PathParam("id") Long id) {
        return selledProductService.getProductById(id)
                .onItem().transform(product -> {
                    if (product == null) {
                        return Response.status(Response.Status.NOT_FOUND).entity(
                                Map.of(MESSAGE_KEY, "Product not found")).build();
                    } else {
                        return Response.ok(product).build();
                    }
                });
    }

    @DELETE
    @Path("{id}")
    @Produces(MediaType.APPLICATION_JSON)
    @Consumes(MediaType.APPLICATION_JSON)
    public Uni<Response> remove(@PathParam("id") Long id) {
        return selledProductService.removeProductById(id)
                .onItem().transform(product -> {
                    if (product == null) {
                        return Response.status(Response.Status.NOT_FOUND).entity(
                                Map.of(MESSAGE_KEY, "Product not found")).build();
                    } else {
                        return Response.ok(Map.of(MESSAGE_KEY, "Product removed successfully")).build();
                    }
                });
    }
}
