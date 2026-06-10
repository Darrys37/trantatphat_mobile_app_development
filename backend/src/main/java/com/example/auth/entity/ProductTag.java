package com.example.auth.entity;

import jakarta.persistence.*;
import lombok.*;
import java.util.UUID;

/**
 * Bảng liên kết: sản phẩm – tag.
 * Quan hệ:
 *   product_tags.product_id → products(id)
 *   product_tags.tag_id     → tags(id)
 */
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
@Entity @Table(name = "product_tags",
    uniqueConstraints = @UniqueConstraint(columnNames = {"product_id", "tag_id"}))
public class ProductTag {

    @Id @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "product_id", nullable = false)
    private Product product;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "tag_id", nullable = false)
    private Tag tag;
}
