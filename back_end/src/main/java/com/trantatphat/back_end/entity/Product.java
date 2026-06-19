package com.trantatphat.back_end.entity;

import jakarta.persistence.*;
import com.fasterxml.jackson.annotation.JsonIgnore;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.ZonedDateTime;
import java.util.UUID;
import java.util.Set;
import java.util.HashSet;
import java.util.List;
import java.util.ArrayList;

@Entity
@Table(name = "products")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Product {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String slug;

    @Column(name = "product_name", nullable = false, length = 255)
    private String name;

    @Column(length = 255)
    private String sku;

    @Column(name = "sale_price", nullable = false)
    private Double salePrice;

    @Column(name = "compare_price")
    private Double comparePrice;

    @Column(name = "buying_price")
    private Double buyingPrice;

    @Column(nullable = false)
    private Integer quantity;

    @Column(name = "short_description", nullable = false, length = 165)
    private String shortDescription;

    @Column(name = "product_description", nullable = false, columnDefinition = "TEXT")
    private String description;

    @Column(name = "product_type", length = 64)
    private String productType;

    private Boolean published;

    @Column(name = "disable_out_of_stock")
    private Boolean disableOutOfStock;

    @Column(columnDefinition = "TEXT")
    private String note;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private ZonedDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at", nullable = false)
    private ZonedDateTime updatedAt;

    @JsonIgnore
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "created_by")
    private User createdBy;

    @JsonIgnore
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "updated_by")
    private User updatedBy;

    @JsonIgnore
    @OneToMany(mappedBy = "product", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<ProductCategory> productCategories = new ArrayList<>();
    
    @JsonIgnore
    @OneToMany(mappedBy = "product", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<Gallery> galleries = new ArrayList<>();

    @JsonIgnore
    @ManyToMany(fetch = FetchType.LAZY)
    @JoinTable(
        name = "product_tags",
        joinColumns = @JoinColumn(name = "product_id"),
        inverseJoinColumns = @JoinColumn(name = "tag_id")
    )
    private Set<Tag> tags = new HashSet<>();

    @Column(nullable = false)
    private Double rating = 0.0;

    @Column(name = "review_count", nullable = false)
    private Integer reviewCount = 0;

    @Transient
    public String getImageUrl() {
        if (galleries != null && !galleries.isEmpty()) {
            return galleries.get(0).getImage();
        }
        return null;
    }
}
