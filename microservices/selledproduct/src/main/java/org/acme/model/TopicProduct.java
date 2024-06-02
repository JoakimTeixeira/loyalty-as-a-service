package org.acme.model;

import org.acme.SelledProduct;

public class TopicProduct {
    private Topic topic;
    private SelledProduct product;

    public TopicProduct() {
        this.topic = this.getTopic();
        this.product = this.getProduct();
    }

    public Topic getTopic() {
        return topic;
    }

    public void setTopic(Topic topic) {
        this.topic = topic;
    }

    public SelledProduct getProduct() {
        return product;
    }

    public void setProduct(SelledProduct product) {
        this.product = product;
    }
}
