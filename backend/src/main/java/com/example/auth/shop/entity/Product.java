package com.example.auth.shop.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.*;
import java.math.BigDecimal;
import java.util.Date;
import java.util.UUID;

@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
@Entity @Table(name = "products")
public class Product {
    @Id @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;
    @Column(nullable = false, unique = true) private String slug;
    @Column(nullable = false) private String product_name;
    private String sku;
    @Column(nullable = false) private BigDecimal sale_price;
    private BigDecimal compare_price;
    private BigDecimal buying_price;
    @Column(nullable = false) private Integer quantity;
    @Column(length = 165, nullable = false) private String short_description;
    @Column(columnDefinition = "TEXT", nullable = false) private String product_description;
    @Column(length = 64) private String product_type; // simple | variable
    private boolean published;
    private boolean disable_out_of_stock;
    private boolean isSale;
    private boolean isNew;
    @Column(columnDefinition = "TEXT") private String note;
    @Column(nullable = false, updatable = false) @Temporal(TemporalType.TIMESTAMP) private Date created_at;
    @Column(nullable = false) @Temporal(TemporalType.TIMESTAMP) private Date updated_at;
    @ManyToOne(fetch = FetchType.LAZY) @JoinColumn(name = "created_by") @JsonIgnore private UserAccount createdBy;
    @ManyToOne(fetch = FetchType.LAZY) @JoinColumn(name = "updated_by") @JsonIgnore private UserAccount updatedBy;
    @PrePersist protected void onCreate() { created_at = new Date(); updated_at = new Date(); }
    @PreUpdate protected void onUpdate() { updated_at = new Date(); }
}
