package com.example.auth.entity;

import jakarta.persistence.*;
import lombok.*;
import java.util.UUID;

/**
 * Giá trị thuộc tính được áp dụng cho sản phẩm cụ thể.
 * Quan hệ:
 *   product_attribute_values.product_attribute_id → product_attributes(id)
 *   product_attribute_values.attribute_value_id   → attribute_values(id)
 */
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
@Entity @Table(name = "product_attribute_values",
    uniqueConstraints = @UniqueConstraint(columnNames = {"product_attribute_id", "attribute_value_id"}))
public class ProductAttributeValue {

    @Id @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "product_attribute_id", nullable = false)
    private ProductAttribute productAttribute;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "attribute_value_id", nullable = false)
    private AttributeValue attributeValue;
}
