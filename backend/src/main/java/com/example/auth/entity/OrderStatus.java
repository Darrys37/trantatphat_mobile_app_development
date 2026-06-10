package com.example.auth.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.*;
import java.util.Date;
import java.util.UUID;

/**
 * Trạng thái đơn hàng (pending, confirmed, shipping, delivered, cancelled…).
 * Quan hệ: created_by / updated_by → staff_accounts(id)
 */
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
@Entity @Table(name = "order_statuses")
public class OrderStatus {

    @Id @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(nullable = false, length = 255)
    private String status_name;

    /** Màu hiển thị badge trên UI, ví dụ: #E53935 */
    @Column(nullable = false, length = 50)
    private String color;

    /** public | private */
    @Column(length = 10)
    private String privacy;

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

    @PrePersist
    protected void onCreate() { created_at = new Date(); updated_at = new Date(); }

    @PreUpdate
    protected void onUpdate() { updated_at = new Date(); }
}
