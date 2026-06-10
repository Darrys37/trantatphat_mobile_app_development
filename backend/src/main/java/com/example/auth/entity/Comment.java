package com.example.auth.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.*;
import java.util.Date;
import java.util.List;
import java.util.UUID;

/**
 * Bảng comment – bình luận dưới mỗi review của sản phẩm.
 * Quan hệ:
 *   comment.review   → reviews(id)     [nhiều comment cho 1 review]
 *   comment.customer → customers(id)   [người viết comment]
 *   comment.parent   → comments(id)    [reply lồng nhau, tuỳ chọn]
 */
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
@Entity @Table(name = "comments")
public class Comment {

    @Id @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    /** Review mà comment này thuộc về */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "review_id", nullable = false)
    @JsonIgnore
    private Review review;

    /** Khách hàng viết comment */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "customer_id", nullable = false)
    private Customer customer;

    /** Comment cha (dùng khi reply một comment khác, nullable) */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "parent_id")
    @JsonIgnore
    private Comment parent;

    /** Danh sách reply con */
    @OneToMany(mappedBy = "parent", cascade = CascadeType.ALL, orphanRemoval = true)
    @JsonIgnore
    private List<Comment> replies;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String content;

    /** Số lượt helpful cho comment */
    @Column(columnDefinition = "INT DEFAULT 0")
    @Builder.Default
    private Integer helpful_count = 0;

    @Column(nullable = false, updatable = false)
    @Temporal(TemporalType.TIMESTAMP)
    private Date created_at;

    @Column(nullable = false)
    @Temporal(TemporalType.TIMESTAMP)
    private Date updated_at;

    @PrePersist
    protected void onCreate() {
        created_at = new Date();
        updated_at = new Date();
        if (helpful_count == null) helpful_count = 0;
    }

    @PreUpdate
    protected void onUpdate() { updated_at = new Date(); }
}
