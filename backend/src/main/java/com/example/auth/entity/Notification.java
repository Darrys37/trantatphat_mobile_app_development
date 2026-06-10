package com.example.auth.entity;

import jakarta.persistence.*;
import lombok.*;
import java.util.Date;
import java.util.UUID;

/**
 * Thông báo nội bộ cho staff.
 * Quan hệ: notifications.account_id → user_accounts(id)
 */
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
@Entity @Table(name = "notifications")
public class Notification {

    @Id @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "account_id")
    private UserAccount account;

    @Column(length = 100)
    private String title;

    @Column(columnDefinition = "TEXT")
    private String content;

    private Boolean seen;

    @Column(nullable = false, updatable = false)
    @Temporal(TemporalType.TIMESTAMP)
    private Date created_at;

    @Temporal(TemporalType.TIMESTAMP)
    private Date receive_time;

    @Temporal(TemporalType.DATE)
    private Date notification_expiry_date;

    @PrePersist
    protected void onCreate() { created_at = new Date(); if (seen == null) seen = false; }
}
