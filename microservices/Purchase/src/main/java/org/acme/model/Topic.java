package org.acme.model;

public class Topic {
    public String TopicName;
    public Topic() {  }
    public Topic(String topicName) {  TopicName = topicName;  }
    @Override
    public String toString() 
    {  return "Topic [TopicName=" + TopicName + "]";  }
}
