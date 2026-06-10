package com.example.auth.entity;

import jakarta.persistence.*;
import lombok.*;
import java.math.BigDecimal;
import java.util.Date;
import java.util.UUID;

/**
 * Mã giảm giá.
 * Quan hệ: dùng trong orders.coupon_id và product_coupons.coupon_id
 */
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
@Entity @Table(name = "coupons")
public class Coupon {

    @Id @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(nullable = false, unique = true, length = 50)
    private String code;

    @Column(precision = 15, scale = 2)
    private BigDecimal discount_value;

    /** percent | fixed */
    @Column(nullable = false, length = 50)
    private String discount_type;

    @Column(nullable = false)
    @Builder.Default
    private Long times_used = 0L;

    private Long max_usage;

    @Column(precision = 15, scale = 2)
    private BigDecimal order_amount_limit;

    @Temporal(TemporalType.TIMESTAMP)
    private Date coupon_start_date;

    @Temporal(TemporalType.TIMESTAMP)
    private Date coupon_end_date;
}
