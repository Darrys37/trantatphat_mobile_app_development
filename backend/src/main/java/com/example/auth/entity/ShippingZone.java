package com.example.auth.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.*;
import java.util.Date;
import java.util.List;
import java.util.UUID;

/**
 * Vùng vận chuyển (ví dụ: Nội thành HCM, Toàn quốc...).
 * Quan hệ:
 *   shipping_zones.created_by → user_accounts(id)
 *   shipping_zones.updated_by → user_accounts(id)
 */
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
@Entity @Table(name = "shipping_zones")
public class ShippingZone {

    @Id @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(nullable = false, length = 255)
    private String name;

    @Column(nullable = false, length = 255)
    private String display_name;

    @Builder.Default
    private Boolean active = false;

    @Builder.Default
    private Boolean free_shipping = false;

    /** price | weight */
    @Column(length = 64)
    private String rate_type;

    @Column(nullable = false, updatable = false)
    @Temporal(TemporalType.TIMESTAMP)
    private Date created_at;

    @Column(nullable = false)
    @Temporal(TemporalType.TIMESTAMP)
    private Date updated_at;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "created_by")
    @JsonIgnore
    private UserAccount createdBy;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "updated_by")
    @JsonIgnore
    private UserAccount updatedBy;

    @OneToMany(mappedBy = "shippingZone", cascade = CascadeType.ALL, orphanRemoval = true)
    @JsonIgnore
    private List<ShippingRate> rates;

    @PrePersist protected void onCreate() { created_at = new Date(); updated_at = new Date(); }
    @PreUpdate  protected void onUpdate() { updated_at = new Date(); }
}
