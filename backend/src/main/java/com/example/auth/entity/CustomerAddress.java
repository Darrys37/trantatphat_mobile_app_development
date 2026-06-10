package com.example.auth.entity;

import jakarta.persistence.*;
import lombok.*;
import java.util.UUID;

/**
 * Địa chỉ giao hàng của khách hàng.
 * Quan hệ: customer_addresses.customer_id → customers(id)
 */
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
@Entity @Table(name = "customer_addresses")
public class CustomerAddress {

    @Id @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "customer_id", nullable = false)
    private Customer customer;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String address_line1;

    @Column(columnDefinition = "TEXT")
    private String address_line2;

    @Column(nullable = false, length = 255)
    private String phone_number;

    @Column(nullable = false, length = 100)
    private String dial_code;

    @Column(nullable = false, length = 255)
    private String country;

    @Column(nullable = false, length = 255)
    private String postal_code;

    @Column(nullable = false, length = 255)
    private String city;

    /** Đánh dấu địa chỉ mặc định */
    @Column(columnDefinition = "BOOLEAN DEFAULT FALSE")
    @Builder.Default
    private Boolean is_default = false;
}
