package com.example.auth.entity;

import jakarta.persistence.*;
import lombok.*;

/**
 * Bảng quốc gia — dùng cho supplier address và shipping zone.
 */
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
@Entity @Table(name = "countries")
public class Country {

    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "countries_seq")
    @SequenceGenerator(name = "countries_seq", sequenceName = "countries_seq", allocationSize = 1)
    private Integer id;

    @Column(nullable = false, length = 2)
    private String iso;

    @Column(nullable = false, length = 80)
    private String name;

    @Column(nullable = false, length = 80)
    private String upper_name;

    @Column(length = 3)
    private String iso3;

    private Short num_code;

    @Column(nullable = false)
    private Integer phone_code;
}
