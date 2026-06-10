package com.example.auth.entity;

import jakarta.persistence.*;
import lombok.*;
import java.math.BigDecimal;
import java.util.UUID;

/**
 * Mức phí vận chuyển theo khoảng giá trị / cân nặng trong một vùng.
 * Quan hệ:
 *   shipping_rates.shipping_zone_id → shipping_zones(id)
 */
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
@Entity @Table(name = "shipping_rates")
public class ShippingRate {

    @Id @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "shipping_zone_id", nullable = false)
    private ShippingZone shippingZone;

    /** g | kg */
    @Column(length = 10)
    private String weight_unit;

    @Column(nullable = false, precision = 15, scale = 3)
    @Builder.Default
    private BigDecimal min_value = BigDecimal.ZERO;

    @Column(precision = 15, scale = 3)
    private BigDecimal max_value;

    /** Không giới hạn max */
    @Builder.Default
    private Boolean no_max = true;

    @Column(nullable = false, precision = 15, scale = 2)
    @Builder.Default
    private BigDecimal price = BigDecimal.ZERO;
}
