package com.example.auth.entity;

import jakarta.persistence.*;
import lombok.*;
import java.util.UUID;

@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
@Entity @Table(name = "attribute_values")
public class AttributeValue {
    @Id @GeneratedValue(strategy = GenerationType.UUID) private UUID id;
    @ManyToOne(fetch = FetchType.LAZY) @JoinColumn(name = "attribute_id", nullable = false) private Attribute attribute;
    @Column(nullable = false) private String attribute_value;
    @Column(length = 50) private String color;
}
