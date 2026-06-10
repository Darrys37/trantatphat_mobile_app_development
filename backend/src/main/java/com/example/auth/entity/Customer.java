package com.example.auth.entity;

import jakarta.persistence.*;
import lombok.*;
import java.util.Date;
import java.util.UUID;

@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
@Entity @Table(name = "customers")
public class Customer {
    @Id @GeneratedValue(strategy = GenerationType.UUID) private UUID id;
    @Column(nullable = false, length = 100) private String first_name;
    @Column(nullable = false, length = 100) private String last_name;
    @Column(nullable = false, unique = true, columnDefinition = "TEXT") private String email;
    @Column(nullable = false, columnDefinition = "TEXT") private String password_hash;
    private boolean active;
    @Column(nullable = false, updatable = false) @Temporal(TemporalType.TIMESTAMP) private Date registered_at;
    @Column(nullable = false) @Temporal(TemporalType.TIMESTAMP) private Date updated_at;
    @PrePersist protected void onCreate() { registered_at = new Date(); updated_at = new Date(); }
    @PreUpdate protected void onUpdate() { updated_at = new Date(); }
}
