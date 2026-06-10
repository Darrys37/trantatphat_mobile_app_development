package com.example.auth.entity;

import jakarta.persistence.*;
import lombok.*;
import java.math.BigDecimal;
import java.util.List;
import java.util.UUID;

/**
 * Một tổ hợp biến thể cụ thể của sản phẩm (ví dụ: Size M – Màu Đen).
 * Quan hệ:
 *   variant_options.product_id → products(id)
 *   variant_options.image_id   → gallery(id)
 */
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
@Entity @Table(name = "variant_options")
public class VariantOption {

    @Id @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String title;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "image_id")
    private Gallery image;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "product_id", nullable = false)
    private Product product;

    @Column(nullable = false, precision = 15, scale = 2)
    @Builder.Default
    private BigDecimal sale_price = BigDecimal.ZERO;

    @Column(precision = 15, scale = 2)
    @Builder.Default
    private BigDecimal compare_price = BigDecimal.ZERO;

    @Column(precision = 15, scale = 2)
    private BigDecimal buying_price;

    @Column(nullable = false)
    @Builder.Default
    private Integer quantity = 0;

    @Column(length = 255)
    private String sku;

    @Builder.Default
    private Boolean active = true;

    @OneToMany(mappedBy = "variantOption", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<Variant> variants;
}
