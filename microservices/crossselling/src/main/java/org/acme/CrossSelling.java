package org.acme;

import org.acme.model.Topic;
import org.json.JSONObject;

public class CrossSelling {
    private Long id;
    private String partnerShop;
    private String recommendedProduct;

    public CrossSelling() {

    }

    public CrossSelling(String partnerShop, String recommendedProduct) {
        this.setPartnerShop(partnerShop);
        this.setRecommendedProduct(recommendedProduct);
    }

    public CrossSelling(Long id, String partnerShop, String recommendedProduct) {
        this.setId(id);
        this.setPartnerShop(partnerShop);
        this.setRecommendedProduct(recommendedProduct);
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getPartnerShop() {
        return partnerShop;
    }

    public void setPartnerShop(String partnerShop) {
        this.partnerShop = partnerShop;
    }

    public String getRecommendedProduct() {
        return recommendedProduct;
    }

    public void setRecommendedProduct(String recommendedProduct) {
        this.recommendedProduct = recommendedProduct;
    }

    @Override
    public String toString() {
        final String TOPIC_EVENT_NAME = Topic.getTopicEventName();

        return new JSONObject().put(TOPIC_EVENT_NAME, new JSONObject()
                .put("partnerShop", getPartnerShop())
                .put("recommendedProduct", getRecommendedProduct()))
                .toString();
    }
}
