package org.acme;

import org.acme.model.Topic;
import org.json.JSONObject;

public class SelledProduct {
    private Long id;
    private Long couponId;
    private Long productsSelledByCoupon;
    private Long shopId;
    private Long productsSelledByShop;
    private String shopLocation;
    private Long productsSelledByLocation;
    private Long loyaltyCardId;
    private Long productsSelledByLoyaltyCard;
    private Long customerId;
    private Long productsSelledByCustomer;

    public SelledProduct() {

    }

    public SelledProduct(
            Long couponId,
            Long productsSelledByCoupon,
            Long shopId,
            Long productsSelledByShop,
            String shopLocation,
            Long productsSelledByLocation,
            Long loyaltyCardId,
            Long productsSelledByLoyaltyCard,
            Long customerId,
            Long productsSelledByCustomer) {
        this.setCouponId(couponId);
        this.setProductsSelledByCoupon(productsSelledByCoupon);
        this.setShopId(shopId);
        this.setProductsSelledByShop(productsSelledByShop);
        this.setShopLocation(shopLocation);
        this.setProductsSelledByLocation(productsSelledByLocation);
        this.setLoyaltyCardId(loyaltyCardId);
        this.setProductsSelledByLoyaltyCard(productsSelledByLoyaltyCard);
        this.setCustomerId(customerId);
        this.setProductsSelledByCustomer(productsSelledByCustomer);
    }

    public SelledProduct(
            Long id,
            Long couponId,
            Long productsSelledByCoupon,
            Long shopId,
            Long productsSelledByShop,
            String shopLocation,
            Long productsSelledByLocation,
            Long loyaltyCardId,
            Long productsSelledByLoyaltyCard,
            Long customerId,
            Long productsSelledByCustomer) {
        this.setId(id);
        this.setCouponId(couponId);
        this.setProductsSelledByCoupon(productsSelledByCoupon);
        this.setShopId(shopId);
        this.setProductsSelledByShop(productsSelledByShop);
        this.setShopLocation(shopLocation);
        this.setProductsSelledByLocation(productsSelledByLocation);
        this.setLoyaltyCardId(loyaltyCardId);
        this.setProductsSelledByLoyaltyCard(productsSelledByLoyaltyCard);
        this.setCustomerId(customerId);
        this.setProductsSelledByCustomer(productsSelledByCustomer);
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Long getCouponId() {
        return couponId;
    }

    public void setCouponId(Long couponId) {
        this.couponId = couponId;
    }

    public Long getProductsSelledByCoupon() {
        return productsSelledByCoupon;
    }

    public void setProductsSelledByCoupon(Long productsSelledByCoupon) {
        this.productsSelledByCoupon = productsSelledByCoupon;
    }

    public Long getShopId() {
        return shopId;
    }

    public void setShopId(Long shopId) {
        this.shopId = shopId;
    }

    public Long getProductsSelledByShop() {
        return productsSelledByShop;
    }

    public void setProductsSelledByShop(Long productsSelledByShop) {
        this.productsSelledByShop = productsSelledByShop;
    }

    public String getShopLocation() {
        return shopLocation;
    }

    public void setShopLocation(String shopLocation) {
        this.shopLocation = shopLocation;
    }

    public Long getProductsSelledByLocation() {
        return productsSelledByLocation;
    }

    public void setProductsSelledByLocation(Long productsSelledByLocation) {
        this.productsSelledByLocation = productsSelledByLocation;
    }

    public Long getLoyaltyCardId() {
        return loyaltyCardId;
    }

    public void setLoyaltyCardId(Long loyaltyCardId) {
        this.loyaltyCardId = loyaltyCardId;
    }

    public Long getProductsSelledByLoyaltyCard() {
        return productsSelledByLoyaltyCard;
    }

    public void setProductsSelledByLoyaltyCard(Long productsSelledByLoyaltyCard) {
        this.productsSelledByLoyaltyCard = productsSelledByLoyaltyCard;
    }

    public Long getCustomerId() {
        return customerId;
    }

    public void setCustomerId(Long customerId) {
        this.customerId = customerId;
    }

    public Long getProductsSelledByCustomer() {
        return productsSelledByCustomer;
    }

    public void setProductsSelledByCustomer(Long productsSelledByCustomer) {
        this.productsSelledByCustomer = productsSelledByCustomer;
    }

    @Override
    public String toString() {
        final String TOPIC_EVENT_NAME = Topic.getTopicEventName();

        return new JSONObject().put(TOPIC_EVENT_NAME, new JSONObject()
                .put("couponId", getCouponId())
                .put("productsSelledByCoupon", getProductsSelledByCoupon())
                .put("shopId", getShopId())
                .put("productsSelledByShop", getProductsSelledByShop())
                .put("shopLocation", getShopLocation())
                .put("productsSelledByLocation", getProductsSelledByLocation())
                .put("loyaltyCardId", getLoyaltyCardId())
                .put("productsSelledByLoyaltyCard", getProductsSelledByLoyaltyCard())
                .put("customerId", getCustomerId())
                .put("productsSelledByCustomer", getProductsSelledByCustomer()))
                .toString();
    }
}
