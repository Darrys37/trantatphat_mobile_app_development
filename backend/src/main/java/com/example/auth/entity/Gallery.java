package com.example.auth.entity;

import jakarta.persistence.*;
import lombok.*;
import java.util.Date;
import java.util.UUID;

@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
@Entity @Table(name = "gallery")
public class Gallery {
    @Id @GeneratedValue(strategy = GenerationType.UUID) private UUID id;
    @ManyToOne(fetch = FetchType.LAZY) @JoinColumn(name = "product_id") private Product product;
    @Column(nullable = false, columnDefinition = "TEXT") private String image;
    @Column(nullable = false, columnDefinition = "TEXT") private String placeholder;
    private boolean is_thumbnail;
    @Column(nullable = false, updatable = false) @Temporal(TemporalType.TIMESTAMP) private Date created_at;
    @Column(nullable = false) @Temporal(TemporalType.TIMESTAMP) private Date updated_at;
    @PrePersist protected void onCreate() { created_at = new Date(); updated_at = new Date(); }
    @PreUpdate protected void onUpdate() { updated_at = new Date(); }
}
