package com.example.auth.entity;

import jakarta.persistence.*;
import lombok.*;
import java.util.UUID;

/**
 * Bảng liên kết: coupon áp dụng cho sản phẩm cụ thể.
 * Quan hệ:
 *   product_coupons.product_id → products(id)
 *   product_coupons.coupon_id  → coupons(id)
 */
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
@Entity @Table(name = "product_coupons",
    uniqueConstraints = @UniqueConstraint(columnNames = {"product_id", "coupon_id"}))
public class ProductCoupon {

    @Id @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "product_id", nullable = false)
    private Product product;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "coupon_id", nullable = false)
    private Coupon coupon;
}
