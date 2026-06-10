package com.example.auth.entity;

import jakarta.persistence.*;
import lombok.*;
import java.util.List;
import java.util.UUID;

/**
 * Một chiều biến thể (ví dụ: "Size", "Color") gắn với variant_option.
 * Quan hệ:
 *   variants.product_id        → products(id)
 *   variants.variant_option_id → variant_options(id)
 */
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
@Entity @Table(name = "variants")
public class Variant {

    @Id @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String variant_option;   // tên chiều: "Size", "Color"

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "product_id", nullable = false)
    private Product product;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "variant_option_id", nullable = false)
    private VariantOption variantOption;

    @OneToMany(mappedBy = "variant", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<VariantValue> values;
}
