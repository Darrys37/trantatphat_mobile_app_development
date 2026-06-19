package com.trantatphat.back_end.entity;

import jakarta.persistence.*;
import lombok.*;

import java.util.UUID;

@Entity
@Table(name = "product_shipping_info")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ProductShippingInfo {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "product_id")
    private Product product;

    @Column(nullable = false)
    private Double weight = 0.0;

    @Column(name = "weight_unit", length = 10)
    private String weightUnit;

    @Column(nullable = false)
    private Double volume = 0.0;

    @Column(name = "volume_unit", length = 10)
    private String volumeUnit;

    @Column(name = "dimension_width", nullable = false)
    private Double dimensionWidth = 0.0;

    @Column(name = "dimension_height", nullable = false)
    private Double dimensionHeight = 0.0;

    @Column(name = "dimension_depth", nullable = false)
    private Double dimensionDepth = 0.0;

    @Column(name = "dimension_unit", length = 10)
    private String dimensionUnit;
}
