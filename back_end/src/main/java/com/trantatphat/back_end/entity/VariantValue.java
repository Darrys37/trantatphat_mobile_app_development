package com.trantatphat.back_end.entity;

import jakarta.persistence.*;
import lombok.*;

import java.util.UUID;

@Entity
@Table(name = "variant_values")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class VariantValue {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "variant_id", nullable = false)
    private Variant variant;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "product_attribute_value_id", nullable = false)
    private ProductAttributeValue productAttributeValue;
}
