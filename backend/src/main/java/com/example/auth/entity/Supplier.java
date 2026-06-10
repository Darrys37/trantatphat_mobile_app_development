package com.example.auth.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.*;
import java.util.Date;
import java.util.UUID;

/**
 * Nhà cung cấp sản phẩm.
 * Quan hệ:
 *   suppliers.country_id  → countries(id)
 *   suppliers.created_by  → user_accounts(id)
 *   suppliers.updated_by  → user_accounts(id)
 */
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
@Entity @Table(name = "suppliers")
public class Supplier {

    @Id @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(nullable = false, length = 255)
    private String supplier_name;

    @Column(length = 255)
    private String company;

    @Column(length = 255)
    private String phone_number;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String address_line1;

    @Column(columnDefinition = "TEXT")
    private String address_line2;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "country_id", nullable = false)
    private Country country;

    @Column(length = 255)
    private String city;

    @Column(columnDefinition = "TEXT")
    private String note;

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

    @PrePersist protected void onCreate() { created_at = new Date(); updated_at = new Date(); }
    @PreUpdate  protected void onUpdate() { updated_at = new Date(); }
}
