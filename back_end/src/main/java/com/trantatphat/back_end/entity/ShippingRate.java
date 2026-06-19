package com.trantatphat.back_end.entity;

import jakarta.persistence.*;
import lombok.*;

import java.util.UUID;

@Entity
@Table(name = "shipping_rates")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ShippingRate {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "shipping_zone_id", nullable = false)
    private ShippingZone shippingZone;

    @Column(name = "weight_unit", length = 10)
    private String weightUnit;

    @Column(name = "min_value", nullable = false)
    private Double minValue = 0.0;

    @Column(name = "max_value")
    private Double maxValue;

    @Column(name = "no_max")
    private Boolean noMax = true;

    @Column(nullable = false)
    private Double price = 0.0;
}
