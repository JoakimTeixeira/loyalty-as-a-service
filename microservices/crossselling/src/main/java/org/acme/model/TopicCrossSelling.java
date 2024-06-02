package org.acme.model;

import org.acme.CrossSelling;

public class TopicCrossSelling {
    private Topic topic;
    private CrossSelling crossSelling;

    public TopicCrossSelling() {
        this.setTopic(topic);
        this.setCrossSelling(crossSelling);
    }

    public Topic getTopic() {
        return topic;
    }

    public void setTopic(Topic topic) {
        this.topic = topic;
    }

    public CrossSelling getCrossSelling() {
        return crossSelling;
    }

    public void setCrossSelling(CrossSelling crossSelling) {
        this.crossSelling = crossSelling;
    }
}
