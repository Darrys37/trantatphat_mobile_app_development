package com.example.auth.entity;

import jakarta.persistence.*;
import lombok.*;
import java.util.UUID;

/**
 * Giá trị cụ thể của một chiều biến thể (ví dụ: "M", "Đen").
 * Quan hệ:
 *   variant_values.variant_id               → variants(id)
 *   variant_values.product_attribute_value_id → product_attribute_values(id)
 */
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
@Entity @Table(name = "variant_values")
public class VariantValue {

    @Id @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "variant_id", nullable = false)
    private Variant variant;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "product_attribute_value_id", nullable = false)
    private ProductAttributeValue productAttributeValue;
}
