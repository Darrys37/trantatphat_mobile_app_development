package com.example.auth.entity;

import jakarta.persistence.*;
import lombok.*;
import java.math.BigDecimal;
import java.util.UUID;

/**
 * Thông tin vận chuyển của sản phẩm (cân nặng, thể tích, kích thước).
 * Quan hệ: product_shipping_info.product_id → products(id)
 */
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
@Entity @Table(name = "product_shipping_info")
public class ProductShippingInfo {

    @Id @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "product_id")
    private Product product;

    @Column(nullable = false, precision = 10, scale = 3)
    @Builder.Default
    private BigDecimal weight = BigDecimal.ZERO;

    /** g | kg */
    @Column(length = 10)
    private String weight_unit;

    @Column(nullable = false, precision = 10, scale = 3)
    @Builder.Default
    private BigDecimal volume = BigDecimal.ZERO;

    /** l | ml */
    @Column(length = 10)
    private String volume_unit;

    @Column(nullable = false, precision = 10, scale = 3)
    @Builder.Default
    private BigDecimal dimension_width = BigDecimal.ZERO;

    @Column(nullable = false, precision = 10, scale = 3)
    @Builder.Default
    private BigDecimal dimension_height = BigDecimal.ZERO;

    @Column(nullable = false, precision = 10, scale = 3)
    @Builder.Default
    private BigDecimal dimension_depth = BigDecimal.ZERO;

    /** cm | m */
    @Column(length = 10)
    private String dimension_unit;
}
