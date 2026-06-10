package com.example.auth.entity;

import jakarta.persistence.*;
import lombok.*;
import java.util.UUID;

@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
@Entity @Table(name = "card_items")
public class CardItem {
    @Id @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "card_id")
    private Card card;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "product_id")
    private Product product;

    @Column(columnDefinition = "INTEGER DEFAULT 1")
    private Integer quantity;

    @Column(length = 10)
    private String selected_size;   // "XS", "S", "M", "L", "XL"

    @Column(length = 50)
    private String selected_color;  // "Black", "Blue", ...
}
