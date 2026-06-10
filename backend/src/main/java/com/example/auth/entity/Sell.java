package com.example.auth.entity;

import jakarta.persistence.*;
import lombok.*;
import java.math.BigDecimal;
import java.util.UUID;

/**
 * Bảng thống kê doanh số theo sản phẩm (tổng hợp từ order_items).
 * Mỗi sản phẩm chỉ có 1 bản ghi (unique product_id).
 * Quan hệ:
 *   sells.product_id → products(id)
 */
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
@Entity @Table(name = "sells")
public class Sell {

    @Id @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "product_id", unique = true, nullable = false)
    private Product product;

    /** Giá bán trung bình tại thời điểm bán */
    @Column(nullable = false, precision = 15, scale = 2)
    private BigDecimal price;

    /** Tổng số lượng đã bán */
    @Column(nullable = false)
    @Builder.Default
    private Integer quantity = 0;
}
