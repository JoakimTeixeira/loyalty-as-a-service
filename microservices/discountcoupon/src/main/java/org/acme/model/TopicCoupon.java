package org.acme.model;

import org.acme.DiscountCoupon;

public class TopicCoupon {
    private Topic topic;
    private DiscountCoupon coupon;

    public TopicCoupon() {
        this.topic = this.getTopic();
        this.coupon = this.getCoupon();
    }

    public Topic getTopic() {
        return topic;
    }

    public void setTopic(Topic topic) {
        this.topic = topic;
    }

    public DiscountCoupon getCoupon() {
        return coupon;
    }

    public void setCoupon(DiscountCoupon coupon) {
        this.coupon = coupon;
    }
}
