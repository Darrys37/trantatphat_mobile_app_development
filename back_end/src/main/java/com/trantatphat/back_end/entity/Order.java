package com.trantatphat.back_end.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.ZonedDateTime;
import java.util.UUID;

@Entity
@Table(name = "orders")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Order {
    @Id
    @Column(length = 50, nullable = false)
    private String id; // VARCHAR(50) primary key

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "coupon_id")
    private Coupon coupon;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id")
    private User user;

    @Column(columnDefinition = "TEXT")
    private String shippingAddress;

    private String paymentMethod;

    private String deliveryMethod;

    private Double totalAmount;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "order_status_id")
    private OrderStatus orderStatus;

    @Column(name = "order_approved_at")
    private ZonedDateTime orderApprovedAt;

    @Column(name = "order_delivered_carrier_date")
    private ZonedDateTime orderDeliveredCarrierDate;

    @Column(name = "order_delivered_customer_date")
    private ZonedDateTime orderDeliveredCustomerDate;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private ZonedDateTime createdAt;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "updated_by")
    private User updatedBy;
}
