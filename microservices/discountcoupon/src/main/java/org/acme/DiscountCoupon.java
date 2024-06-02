package org.acme;

import org.acme.model.Topic;
import org.json.JSONObject;
import java.time.LocalDate;

public class DiscountCoupon {
    private Long id;
    private String discount;
    private LocalDate expiryDate;

    public DiscountCoupon() {

    }

    public DiscountCoupon(String discount, LocalDate expiryDate) {
        this.setDiscount(discount);
        this.setExpiryDate(expiryDate);
    }

    public DiscountCoupon(Long id, String discount, LocalDate expiryDate) {
        this.setId(id);
        this.setDiscount(discount);
        this.setExpiryDate(expiryDate);
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getDiscount() {
        return discount;
    }

    public void setDiscount(String discount) {
        this.discount = discount;
    }

    public LocalDate getExpiryDate() {
        return expiryDate;
    }

    public void setExpiryDate(LocalDate expiryDate) {
        this.expiryDate = expiryDate;
    }

    @Override
    public String toString() {
        final String TOPIC_EVENT_NAME = Topic.getTopicEventName();

        return new JSONObject().put(TOPIC_EVENT_NAME, new JSONObject()
                .put("discount", getDiscount())
                .put("expiryDate", getExpiryDate()))
                .toString();
    }
}
