package org.acme.model;

public class Topic {
    private String topicName;
    private static final String TOPIC_EVENT_NAME = "Purchase_Event";

    public Topic() {

    }

    public Topic(String name) {
        this.setTopicName(name);
    }

    public String getTopicName() {
        return topicName;
    }

    public void setTopicName(String name) {
        this.topicName = name;
    }

    public static String getTopicEventName() {
        return TOPIC_EVENT_NAME;
    }

    @Override
    public String toString() {
        return "Topic [topicName=" + this.getTopicName() + "]";
    }
}
