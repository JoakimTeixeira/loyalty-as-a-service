package org.acme;

import org.acme.model.TopicCrossSelling;
import org.acme.model.Topic;

import io.smallrye.mutiny.Multi;
import io.smallrye.mutiny.Uni;

import jakarta.inject.Inject;
import jakarta.ws.rs.*;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;

import java.util.Map;

@Path("/CrossSelling")
public class CrossSellingResource {
    private final CrossSellingService crossSellingService;
    private final CrossSellingProducer crossSellingProducer;

    private static final String MESSAGE_KEY = "message";

    @Inject
    public CrossSellingResource(
            CrossSellingService crossSellingService,
            CrossSellingProducer crossSellingProducer) {
        this.crossSellingService = crossSellingService;
        this.crossSellingProducer = crossSellingProducer;
    }

    @POST
    @Path("Consume")
    @Produces(MediaType.APPLICATION_JSON)
    @Consumes(MediaType.APPLICATION_JSON)
    public Uni<Response> provisioningConsumer(Topic topic) {
        try {
            Thread worker = new

            CrossSellingConsumer(crossSellingService, topic.getTopicName());
            worker.start();
            return Uni.createFrom().item(Response.ok().entity(
                    Map.of(MESSAGE_KEY, "New worker started: " + topic.getTopicName())).build());
        } catch (

        Exception e) {
            e.printStackTrace();
            return Uni.createFrom().item(Response.serverError().entity(
                    Map.of(MESSAGE_KEY, "Failed to start worker")).build());
        }
    }

    @GET
    @Produces(MediaType.APPLICATION_JSON)
    @Consumes(MediaType.APPLICATION_JSON)
    public Multi<CrossSelling> getAll() {
        return crossSellingService.getAllRecommendations();
    }

    @POST
    @Produces(MediaType.APPLICATION_JSON)
    @Consumes(MediaType.APPLICATION_JSON)
    public Uni<Response> generateCrossSelling(TopicCrossSelling request) {
        String topicName = request.getTopic().getTopicName();
        CrossSelling crossSelling = request.getCrossSelling();

        return crossSellingProducer.topicExists(topicName)
                .onItem().transformToUni(exists -> {
                    if (!exists.booleanValue()) {
                        return handleTopicCreation(topicName).onItem().transformToUni(
                                response ->

                                crossSellingProducer.sendCrossSellingMessage(topicName, crossSelling));
                    } else

                {
                        return

                crossSellingProducer.sendCrossSellingMessage(topicName, crossSelling);
                    }

                });
    }

    private Uni<Response> handleTopicCreation(String topicName) {
        return crossSellingProducer.createTopic(topicName)
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
        return crossSellingService.getRecommendationById(id)
                .onItem().transform(crossSelling -> {
                    if (crossSelling == null) {
                        return Response.status(Response.Status.NOT_FOUND).entity(
                                Map.of(MESSAGE_KEY, "Cross Selling not found")).build();
                    } else {
                        return Response.ok(crossSelling).build();
                    }
                });
    }

    @DELETE
    @Path("{id}")
    @Produces(MediaType.APPLICATION_JSON)
    @Consumes(MediaType.APPLICATION_JSON)
    public Uni<Response> remove(@PathParam("id") Long id) {
        return crossSellingService.removeRecommendationById(id)
                .onItem().transform(crossSelling -> {
                    if (crossSelling == null) {
                        return Response.status(Response.Status.NOT_FOUND).entity(
                                Map.of(MESSAGE_KEY, "Cross Selling not found")).build();
                    } else {
                        return Response.ok(Map.of(MESSAGE_KEY, "Cross Selling removed successfully")).build();
                    }
                });
    }
}
