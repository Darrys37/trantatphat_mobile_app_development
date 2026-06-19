package com.trantatphat.back_end.entity;

import jakarta.persistence.*;
import lombok.*;

import java.util.UUID;

@Entity
@Table(name = "variant_options")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class VariantOption {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String title;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "image_id")
    private Gallery image;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "product_id", nullable = false)
    private Product product;

    @Column(name = "sale_price", nullable = false)
    private Double salePrice = 0.0;

    @Column(name = "compare_price")
    private Double comparePrice = 0.0;

    @Column(name = "buying_price")
    private Double buyingPrice;

    @Column(nullable = false)
    private Integer quantity = 0;

    @Column(length = 255)
    private String sku;

    private Boolean active = true;
}
