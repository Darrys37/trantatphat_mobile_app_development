package com.example.auth.entity;

import jakarta.persistence.*;
import lombok.*;
import java.util.UUID;

/**
 * Bảng liên kết: sản phẩm – nhà cung cấp.
 * Quan hệ:
 *   product_suppliers.product_id  → products(id)
 *   product_suppliers.supplier_id → suppliers(id)
 */
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
@Entity @Table(name = "product_suppliers",
    uniqueConstraints = @UniqueConstraint(columnNames = {"product_id", "supplier_id"}))
public class ProductSupplier {

    @Id @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "product_id", nullable = false)
    private Product product;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "supplier_id", nullable = false)
    private Supplier supplier;
}
