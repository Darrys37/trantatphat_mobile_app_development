package com.example.auth.entity;

import jakarta.persistence.*;
import lombok.*;
import java.util.List;
import java.util.UUID;

/**
 * Thuộc tính áp dụng cho sản phẩm (size, color...).
 * Quan hệ:
 *   product_attributes.product_id   → products(id)
 *   product_attributes.attribute_id → attributes(id)
 */
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
@Entity @Table(name = "product_attributes",
    uniqueConstraints = @UniqueConstraint(columnNames = {"product_id", "attribute_id"}))
public class ProductAttribute {

    @Id @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "product_id", nullable = false)
    private Product product;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "attribute_id", nullable = false)
    private Attribute attribute;

    @OneToMany(mappedBy = "productAttribute", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<ProductAttributeValue> values;
}
