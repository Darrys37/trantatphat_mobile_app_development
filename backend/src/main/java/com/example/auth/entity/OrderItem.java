package com.example.auth.entity;

import jakarta.persistence.*;
import lombok.*;
import java.math.BigDecimal;
import java.util.UUID;

/**
 * Chi tiết sản phẩm trong đơn hàng.
 * Quan hệ:
 *   order_items.order_id   → orders(id)
 *   order_items.product_id → products(id)
 */
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
@Entity @Table(name = "order_items")
public class OrderItem {

    @Id @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "order_id", nullable = false)
    private Order order;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "product_id")
    private Product product;

    @Column(nullable = false, precision = 15, scale = 2)
    private BigDecimal price;

    @Column(nullable = false)
    private Integer quantity;

    /** Variant đã chọn (size, màu...) – lưu dạng JSON string */
    @Column(columnDefinition = "TEXT")
    private String selected_variant;
}
