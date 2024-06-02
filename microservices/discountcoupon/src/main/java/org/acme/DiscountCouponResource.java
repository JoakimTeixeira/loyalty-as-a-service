package org.acme;

import org.acme.model.TopicCoupon;
import org.acme.model.Topic;

import io.smallrye.mutiny.Multi;
import io.smallrye.mutiny.Uni;

import jakarta.inject.Inject;
import jakarta.ws.rs.*;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;

import java.util.Map;

@Path("/DiscountCoupon")
public class DiscountCouponResource {
    private final DiscountCouponService discountCouponService;
    private final DiscountCouponProducer discountCouponProducer;

    private static final String MESSAGE_KEY = "message";

    @Inject
    public DiscountCouponResource(
            DiscountCouponService discountCouponService,
            DiscountCouponProducer discountCouponProducer) {
        this.discountCouponService = discountCouponService;
        this.discountCouponProducer = discountCouponProducer;
    }

    @POST
    @Path("Consume")
    @Produces(MediaType.APPLICATION_JSON)
    @Consumes(MediaType.APPLICATION_JSON)
    public Uni<Response> provisioningConsumer(Topic topic) {
        try {
            Thread worker = new DiscountCouponConsumer(discountCouponService, topic.getTopicName());
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
    public Multi<DiscountCoupon> getAll() {
        return discountCouponService.getAllCoupons();
    }

    @POST
    @Produces(MediaType.APPLICATION_JSON)
    @Consumes(MediaType.APPLICATION_JSON)
    public Uni<Response> generateDiscountCoupon(TopicCoupon request) {
        String topicName = request.getTopic().getTopicName();
        DiscountCoupon coupon = request.getCoupon();

        return discountCouponProducer.topicExists(topicName)
                .onItem().transformToUni(exists -> {
                    if (!exists.booleanValue()) {
                        return handleTopicCreation(topicName).onItem().transformToUni(
                                response -> discountCouponProducer.sendDiscountCouponMessage(topicName, coupon));
                    } else {
                        return discountCouponProducer.sendDiscountCouponMessage(topicName, coupon);
                    }
                });
    }

    private Uni<Response> handleTopicCreation(String topicName) {
        return discountCouponProducer.createTopic(topicName)
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
        return discountCouponService.getCouponById(id)
                .onItem().transform(coupon -> {
                    if (coupon == null) {
                        return Response.status(Response.Status.NOT_FOUND).entity(
                                Map.of(MESSAGE_KEY, "Coupon not found")).build();
                    } else {
                        return Response.ok(coupon).build();
                    }
                });
    }

    @DELETE
    @Path("{id}")
    @Produces(MediaType.APPLICATION_JSON)
    @Consumes(MediaType.APPLICATION_JSON)
    public Uni<Response> remove(@PathParam("id") Long id) {
        return discountCouponService.removeCouponById(id)
                .onItem().transform(coupon -> {
                    if (coupon == null) {
                        return Response.status(Response.Status.NOT_FOUND).entity(
                                Map.of(MESSAGE_KEY, "Coupon not found")).build();
                    } else {
                        return Response.ok(Map.of(MESSAGE_KEY, "Coupon removed successfully")).build();
                    }
                });
    }
}
