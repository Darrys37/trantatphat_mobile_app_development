package com.example.auth.shop.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.*;
import java.util.Date;
import java.util.List;
import java.util.UUID;

@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
@Entity @Table(name = "attributes")
public class Attribute {
    @Id @GeneratedValue(strategy = GenerationType.UUID) private UUID id;
    @Column(nullable = false) private String attribute_name;
    @Column(nullable = false, updatable = false) @Temporal(TemporalType.TIMESTAMP) private Date created_at;
    @Column(nullable = false) @Temporal(TemporalType.TIMESTAMP) private Date updated_at;
    @ManyToOne(fetch = FetchType.LAZY) @JoinColumn(name = "created_by") @JsonIgnore private UserAccount createdBy;
    @ManyToOne(fetch = FetchType.LAZY) @JoinColumn(name = "updated_by") @JsonIgnore private UserAccount updatedBy;
    @OneToMany(mappedBy = "attribute", cascade = CascadeType.ALL) @JsonIgnore private List<AttributeValue> values;
    @PrePersist protected void onCreate() { created_at = new Date(); updated_at = new Date(); }
    @PreUpdate protected void onUpdate() { updated_at = new Date(); }
}
