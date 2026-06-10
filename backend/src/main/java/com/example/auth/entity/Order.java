package com.example.auth.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.*;
import java.math.BigDecimal;
import java.util.Date;
import java.util.List;

/**
 * Đơn hàng.
 * Quan hệ:
 *   orders.customer_id       → customers(id)
 *   orders.coupon_id         → coupons(id)
 *   orders.order_status_id   → order_statuses(id)
 *   orders.shipping_address_id → customer_addresses(id)
 *   orders.updated_by        → user_accounts(id)  [staff xử lý đơn]
 */
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
@Entity @Table(name = "orders")
public class Order {

    /** Mã đơn hàng dạng VARCHAR như ORD-20240101-001 */
    @Id
    @Column(length = 50)
    private String id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "customer_id")
    private Customer customer;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "coupon_id")
    private Coupon coupon;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "order_status_id")
    private OrderStatus orderStatus;

    /** Địa chỉ giao hàng được chọn lúc đặt */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "shipping_address_id")
    private CustomerAddress shippingAddress;

    @Column(precision = 15, scale = 2)
    private BigDecimal total_amount;

    @Column(precision = 15, scale = 2)
    private BigDecimal discount_amount;

    @Column(precision = 15, scale = 2)
    private BigDecimal shipping_fee;

    @Temporal(TemporalType.TIMESTAMP)
    private Date order_approved_at;

    @Temporal(TemporalType.TIMESTAMP)
    private Date order_delivered_carrier_date;

    @Temporal(TemporalType.TIMESTAMP)
    private Date order_delivered_customer_date;

    @Column(nullable = false, updatable = false)
    @Temporal(TemporalType.TIMESTAMP)
    private Date created_at;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "updated_by")
    @JsonIgnore
    private UserAccount updatedBy;

    @OneToMany(mappedBy = "order", cascade = CascadeType.ALL, orphanRemoval = true)
    @JsonIgnore
    private List<OrderItem> items;

    @PrePersist
    protected void onCreate() { created_at = new Date(); }
}
