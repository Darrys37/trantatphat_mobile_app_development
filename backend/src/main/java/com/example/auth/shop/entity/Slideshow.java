package com.example.auth.shop.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.*;
import java.util.Date;
import java.util.UUID;

@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
@Entity @Table(name = "slideshows")
public class Slideshow {
    @Id @GeneratedValue(strategy = GenerationType.UUID) private UUID id;
    @Column(length = 80) private String title;
    @Column(columnDefinition = "TEXT") private String destination_url;
    @Column(nullable = false, columnDefinition = "TEXT") private String image;
    @Column(nullable = false, columnDefinition = "TEXT") private String placeholder;
    @Column(length = 160) private String description;
    @Column(length = 50) private String btn_label;
    @Column(nullable = false) private Integer displayOrder; 
    private boolean published;
    @Column(nullable = false) private Integer clicks = 0;
    @Column(columnDefinition = "TEXT") private String styles;
    @Column(nullable = false, updatable = false) @Temporal(TemporalType.TIMESTAMP) private Date created_at;
    @Column(nullable = false) @Temporal(TemporalType.TIMESTAMP) private Date updated_at;
    @ManyToOne(fetch = FetchType.LAZY) @JoinColumn(name = "created_by") @JsonIgnore private UserAccount createdBy;
    @ManyToOne(fetch = FetchType.LAZY) @JoinColumn(name = "updated_by") @JsonIgnore private UserAccount updatedBy;
    @PrePersist protected void onCreate() { created_at = new Date(); updated_at = new Date(); if (clicks == null) clicks = 0; }
    @PreUpdate protected void onUpdate() { updated_at = new Date(); }
}
