package com.example.auth.entity;

import jakarta.persistence.*;
import lombok.*;
import java.util.Date;
import java.util.UUID;

@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
@Entity @Table(name = "favorites",
  uniqueConstraints = @UniqueConstraint(columnNames = {"customer_id", "product_id"}))
public class Favorite {

    @Id @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "customer_id", nullable = false)
    private Customer customer;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "product_id", nullable = false)
    private Product product;

    @Column(length = 10)
    private String selected_size;   // "XS", "S", "M", "L", "XL"

    @Column(length = 50)
    private String selected_color;  // "Black", "Blue", ...

    @Column(nullable = false, updatable = false)
    @Temporal(TemporalType.TIMESTAMP)
    private Date created_at;

    @PrePersist
    protected void onCreate() { created_at = new Date(); }
}